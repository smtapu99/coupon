class Coupon < ApplicationRecord
  include ActsAsExportable
  include ActAsEdgeCachable
  include ClearsCustomCaches
  include ActsAsSiteable
  include ActiveModel::Dirty
  include ActsAsFilterable
  include ActsAsStatusable

  has_statuses(
    active: 'active',
    blocked: 'blocked',
    pending: 'pending'
  )

  INFO_FIELDS = %w(info_discount info_min_purchase info_limited_clients info_limited_brands info_conditions).freeze

  attr_accessor :l, :sl, :origin_coupon_form, :coupon_id, :start_date_from, :start_date_to, :end_date_from, :end_date_to, :include_expired, :migrated, :shop_slugs

  delegate :slug, :title, to: :shop, prefix: true, allow_nil: true
  delegate :slug, :name, to: :affiliate_network, prefix: true, allow_nil: true

  before_validation :sanitize_whitespaces
  before_save :prioritize_exclusive_coupons

  # Validation
  validates_presence_of :title, :site_id, :shop_id, :coupon_type, :affiliate_network_id, :url, :start_date, :end_date

  validates :affiliate_network, associated: true
  validates :shop_list_priority, numericality: { greater_than_or_equal: 1, less_than_or_equal_to: 5 }
  validates :url, url: true
  validate :shop_id_not_zero
  validates_uniqueness_of :site_id, scope: [:shop_id, :title, :start_date, :end_date, :code], message: 'This coupon already exists'
  validate :subid_placeholder_present, if: :validate_subid_placeholder?
  validate :site_id_valid
  validate :coupon_or_offer
  validate :coupon_type_valid

  # File Uploader
  mount_uploader :logo, Admin::CouponUploader if ENV['RAKE_IMPORT'].nil?
  mount_uploader :widget_header_image, Admin::CouponUploader if ENV['RAKE_IMPORT'].nil?

  # Associations
  belongs_to :shop
  belongs_to :affiliate_network

  has_many :alerts, as: :alertable, dependent: :destroy
  has_many :coupon_categories
  has_many :categories, through: :coupon_categories, validate: false

  has_one  :shops_html_document, through: :shop, source: :html_document

  has_many :campaigns_coupons, dependent: :destroy
  has_many :campaigns, through: :campaigns_coupons
  has_many :coupon_codes

  scope :coupons_by_site, ->(id) { id.present? ? where(site_id: id) : self }
  scope :select_by_type_desktop, ->(type) { select{ |c| c.coupon_type == type && c.is_mobile == false } }
  scope :select_by_type_mobile, ->(type) { select{ |c| c.coupon_type == type } }
  scope :to_validate, -> { where('(validated_at IS NULL OR validated_at < ?) AND (last_validation_at IS NULL OR last_validation_at < ?)', Time.zone.now - 2.days, Time.zone.now - 1.day) }
  scope :with_active_site, -> { joins(:site).where(sites: { status: 'active' }) }

  scope :unexpired, -> { where('coupons.start_date <= :current_date AND coupons.end_date >= :current_date', { current_date: Time.zone.now }) }
  scope :status_active, -> { joins(:shop).where(status: 'active', shops: { status: 'active' }) }
  scope :active, -> { status_active.unexpired }

  scope :active_and_visible, -> { active.visible }
  scope :by_shops, ->(shops) do
    shops = shops.ids if shops.is_a?(ActiveRecord::Associations::CollectionProxy)
    where(shop_id: shops)
  end

  scope :by_categories, ->(categories) do
    categories = categories.ids if categories.is_a?(ActiveRecord::Associations::CollectionProxy)
    includes(:categories).where(categories: { id: categories })
  end

  scope :by_campaigns, ->(campaigns) do
    campaigns = campaigns.ids if campaigns.is_a?(ActiveRecord::Associations::CollectionProxy)
    includes(:campaigns).where(campaigns: { id: campaigns })
  end

  scope :by_category_slugs, ->(slugs) do
    includes(:categories).where(categories: { slug: slugs })
  end

  scope :order_by_exclusive_and_top, -> {
    order(Arel.sql('CASE WHEN coupons.is_exclusive = 1 THEN 1 WHEN coupons.is_top = 1 THEN 2 ELSE 3 END ASC, coupons.priority_score DESC'))
  }

  # used for migration with zero downtime.
  # disables writes to the rejected colums
  def self.columns
    super.reject do |column|
      [
        'is_imported',
        'mini_title',
        'ranking_value',
        'commission_value',
        'commission_type',
        'logo_color',
        'coupon_of_the_week',
        'is_international',
        'tracking_platform_campaign_id',
        'tracking_platform_banner_id',
        'old_url',
        'shop_slider_position',
        'campaign_id'
      ].include?(column.name.to_s)
    end
  end

  def self.validate!
    update_all(validated_at: Time.zone.now, last_validation_at: Time.zone.now)
  end

  def self.invalidate!
    update_all(validated_at: nil, last_validation_at: Time.zone.now)
  end

  def joined_category_slugs
    categories.map(&:slug).join(',') if categories.present?
  end

  def joined_campaign_slugs
    campaigns.map(&:slug).join(',') if campaigns.present?
  end

  def item_id
    "coupon-#{id}"
  end

  def self.to_export_xls
    xls = Axlsx::Package.new
    xls.workbook do |wb|
      wb.add_worksheet(name: "coupons_#{Time.now.to_date}") do |sheet|
        sheet.add_row CouponCode::CSV_EXPORT_COLUMN_HEADERS[:coupon].values

        all.each do |coupon|
          Time.zone = coupon.site.timezone
          sheet.add_row coupon.csv_mapped_attributes
        end
      end
    end
    xls
  end

  def self.to_export_csv(options = {})
    CSV.generate(options) do |csv|
      csv << Coupon::CSV_EXPORT_COLUMN_HEADERS[:coupon].values
      all.each do |coupon|
        csv << coupon.csv_mapped_attributes
      end
    end
  end

  # CA-1006
  # calculates the priorities of the coupons based on the following formula
  #
  # (clicks / days online) x shops.clickout_value x (number of prios / prio)
  def self.calculate_priorities(sites = nil)
    transaction do
      raise ActiveRecord::Rollback unless self.coupons_by_site(sites).active.joins(:shop).update_all(priority_query)
    end
  end

  def calculate_priority
    transaction do
      raise ActiveRecord::Rollback unless self.class.joins(:shop).where(id: id).update_all(self.class.priority_query)
    end
  end

  def self.priority_query
    "
    coupons.priority_score =
      IF((
        @score := ROUND(
          IFNULL(
            (
              IF(coupons.clicks = 0, 1, coupons.clicks)
              /
              IF((@diff:= (datediff(NOW(), COALESCE(coupons.start_date, coupons.created_at)))) > 0, @diff, 1)
              * IF(clickout_value = 0, 0.00001, shops.clickout_value)
              * (#{Shop::PRIORITY_COUNT} / shops.tier_group)
            )
          , 0)
        , 5)
      ) >= 99999, 99999, @score)
    "
  end

  def random_clickouts_today
    Rails.cache.fetch([site_id, id, 'rand_clickout_count'], expires_in: 24.hours) do
      count = (priority_score * rand(2..50)).round
      count = rand(120..350) if count > 350
      count
    end
  end

  def self.filter_by_expired?(expired)
    return true if expired.to_s == 'true'
    false
  end

  def self.grid_filter(params)
    params = ActiveSupport::HashWithIndifferentAccess.new(params)

    query = grid_filter_base(params)
    query = query.where('coupons.start_date >= ?', string_to_utc_time('start_date_from', params['start_date_from'])) if params['start_date_from'].present?
    query = query.where('coupons.start_date <= ?', string_to_utc_time('start_date_to', params['start_date_to'])) if params['start_date_to'].present?

    query = query.where('coupons.end_date >= ?', string_to_utc_time('end_date_from', params['end_date_from'])) if params['end_date_from'].present?
    query = query.where('coupons.end_date <= ?', string_to_utc_time('end_date_to', params['end_date_to'])) if params['end_date_to'].present?

    query = query.where('coupons.created_at >= ?', string_to_utc_time('created_at_from', params['created_at_from'])) if params['created_at_from'].present?
    query = query.where('coupons.created_at <= ?', string_to_utc_time('created_at_to', params['created_at_to'])) if params['created_at_to'].present?

    query = query.expired(filter_by_expired?(params[:expired])) if params[:expired] != 'all'

    query
  end

  def self.expired_exclusive(params)
    grid_filter_base(params).where(is_exclusive: true).expired
  end

  def self.invalid_urls_filter(params)
    query = grid_filter_base(params)
      .active_and_visible
      .joins('INNER JOIN affiliate_networks on affiliate_networks.id = coupons.affiliate_network_id AND affiliate_networks.validation_regex IS NOT NULL')
      .where('coupons.url NOT REGEXP affiliate_networks.validation_regex')

    query = query.where('coupons.url like ?', "%#{params[:url]}%") if params[:url].present?
    query = query.where('affiliate_networks.slug like ?', "%#{params[:affiliate_network_slug]}%") if params[:affiliate_network_slug].present?
    query
  end

  def self.export(params)
    if params[:site_ids].present? && params[:site_ids].reject(&:blank?).present?
      site_ids = params[:site_ids].reject(&:blank?)
    else
      site_ids = []
    end
    shop_slugs = params[:shop_slugs].present? && params[:shop_slugs].split(',').map(&:strip)

    query = includes(:categories).references(:categories)
    query = query.includes(:shop).references(:shop)
    query = query.includes(:affiliate_network).references(:affiliate_network)

    query = query.where(site_id: site_ids) if site_ids.present?
    query = query.where(shop_id: params[:shop_ids].reject(&:blank?)) if params[:shop_ids].present? && params[:shop_ids].reject(&:blank?).present?
    query = query.where(shops: { slug: shop_slugs }) if shop_slugs.present?
    query = query.where(shops: { status: params[:shop_status] }) if params[:shop_status].present? && params[:shop_status].reject(&:blank?).present?
    query = query.where(shops: { tier_group: params[:shop_tier_group] }) if params[:shop_tier_group].present? && params[:shop_tier_group].reject(&:blank?).present?
    query = query.by_categories(params[:category_ids].reject(&:blank?)) if params[:category_ids].present? && params[:category_ids].reject(&:blank?).present?
    query = query.by_campaigns(params[:campaign_ids].reject(&:blank?)) if params[:campaign_ids].present? && params[:campaign_ids].reject(&:blank?).present?
    query = query.where(status: params[:status].reject(&:blank?)) if params[:status].present? && params[:status].reject(&:blank?).present?
    query = query.where(coupon_type: params[:coupon_type]) if params[:coupon_type].present?

    query = query.where('coupons.start_date >= ?', concat_datetime('start_date_from', params)) if params['start_date_from(1i)'].present?
    query = query.where('coupons.start_date <= ?', concat_datetime('start_date_to', params)) if params['start_date_to(1i)'].present?

    query = query.where('coupons.end_date >= ?', concat_datetime('end_date_from', params)) if params['end_date_from(1i)'].present?
    query = query.where('coupons.end_date <= ?', concat_datetime('end_date_to', params)) if params['end_date_to(1i)'].present?

    if params['include_expired'].to_i.zero? && params['start_date_from(1i)'].blank? && params['start_date_to(1i)'].blank? && params['end_date_from(1i)'].blank? && params['end_date_to(1i)'].blank?
      query = query.unexpired
    end

    query = query.where(affiliate_network_id: params[:affiliate_network_id].reject(&:blank?)) if params[:affiliate_network_id].present? && params[:affiliate_network_id].reject(&:blank?).present?
    query = query.where('coupons.created_at >= ?', concat_datetime('created_at_from', params)) if params['created_at_from(1i)'].present?
    query = query.where('coupons.created_at <= ?', concat_datetime('created_at_to', params)) if params['created_at_to(1i)'].present?

    query
  end

  # Gets coupon status statistic as hash
  #
  # @return [hash]
  # @example e.g \\{"active" => 100, "blocked" => 6, "pending" => 50\}
  def self.stats
    defaults = { 'active' => 0, 'blocked' => 0, 'pending' => 0 }
    allowed_sites = Site.current ? Site.current.id : User.current.get_current_user_sites
    stats = where(site_id: allowed_sites).group(:status).count
    defaults.merge(stats)
  end

  def self.one_by_shop
    group('coupons.shop_id')
  end

  def self.get_by_role
    if Site.current then
      Site.current.coupons
    else
      User.current.coupons
    end
  end

  def self.with_valid_coupon_type(type)
    if type.to_sym == :coupon
      where('coupon_type = "coupon" && code IS NOT NULL && code != ""')
    else
      where('coupon_type = "offer" OR (coupon_type="coupon" AND (code IS NULL OR code=""))')
    end
  end

  def self.with_logo
    where('coupons.logo IS NOT NULL')
  end

  # @todo: add sort method to consider rankingvalue too (see old query)
  def self.get_base_query
    get_by_role
      .includes(:shop)
      .includes(:categories)
      .unexpired
      .order('clicks DESC')
  end

  def self.get_start_date_greater_enddate
    get_by_role.where('start_date > end_date').includes(:shop)
  end

  def self.get_possible_not_working(quantity = 20)
    get_by_role
      .where('coupons.end_date >= ?', Time.zone.now)
      .where('coupons.negative_votes> ?', 2)
      .limit(quantity)
  end

  # 1. manual order first (if coupon changed position it stays in the new position the rest of the coupons are filled out according to the normal shop logic
  # 2. Coupon codes go first
  # 2.1. Newest (set in backend e.g. last week) coupon codes go first
  # 2.1.1. Newest coupon codes with highest saving go first
  # 2.2 Offers go after coupon codes
  # 2.2 newest offers go first
  # 2.2.1 newest offers with highest saving amount go first
  #
  def self.order_by_relevance
    order(Arel.sql("
      CASE WHEN order_position is not null THEN 1 ELSE 0 END DESC,
      order_position ASC,
      CASE WHEN coupon_type = 'coupon' THEN 1 ELSE 0 END DESC,
      CASE WHEN code IS NOT NULL AND code != '' THEN 1 ELSE 0 END DESC,
      DATE(coupons.start_date) DESC,
      savings DESC
    "))
  end

  # CA-1006
  # for coupon lists outside the shop page formula:
  # (clicks per coupon / days online) x clickout value x (number of prios / prio)
  # the priority_score is calculated hourly with rake calculate_priorities:coupons
  def self.order_by_priority
    order(Arel.sql("
      CASE WHEN coupon_type = 'coupon' AND code IS NOT NULL AND code != '' THEN 0 ELSE 1 END ASC,
      coupons.priority_score DESC
    "))
  end

  def self.order_by_campaign_priority(set = nil)
    if set.present?
      order_string = set.map { |id| "coupons.id=#{id} DESC" }.join(',')
      order(Arel.sql("#{order_string}, CASE WHEN coupon_type = 'coupon' AND code IS NOT NULL AND code != '' THEN 0 ELSE 1 END ASC,
        coupons.priority_score DESC"))
    else
      order(Arel.sql("
        CASE WHEN coupon_type = 'coupon' AND code IS NOT NULL AND code != '' THEN 0 ELSE 1 END ASC,
        coupons.priority_score DESC
      "))
    end
  end

  # Trello: #203-coupons-order-rule-not-working
  # redefined shop list priority
  #
  # previously defined in ticket CA-1031 as:
  # self.order("
  #   coupons.shop_list_priority ASC,
  #   DATE(coupons.start_date) DESC,
  #   savings DESC
  # ")
  def self.order_by_shop_list_priority
    order(Arel.sql("
      coupons.shop_list_priority ASC,
      CASE WHEN coupons.is_exclusive = true THEN 0 ELSE 1 END ASC,
      CASE WHEN coupons.is_editors_pick = true THEN 0 ELSE 1 END ASC,
      CASE WHEN coupon_type = 'coupon' AND code IS NOT NULL AND code != '' THEN 0 ELSE 1 END ASC,
      DATE(coupons.start_date) DESC,
      savings DESC
    "))
  end

  def self.get_top(quantity = 20)
    get_base_query
      .where(is_top: 1)
      .limit(quantity)
  end

  def self.general
    by_type 'general'
  end

  def self.by_type(type, opts={})
    case type.to_s
    when 'popular'
      query = order('coupons.clicks DESC').limit(20)
    when 'new'
      days_new = Setting::get('publisher_site.days_coupon_is_new', default: 3)

      query = where('coupons.start_date >= ?', days_new.to_i.days.ago)
    when 'expiring'
      query = where('coupons.end_date <= ?', Time.zone.now + 3.days)
    else
      query = where("coupons.is_#{type} = ?", 1)
    end

    if opts[:exclude].present?
      query = query.where('coupons.id NOT IN (?)', opts[:exclude].map(&:id))
    end

    query
  end

  def self.order_by_set(set)
    return self unless set.present?
    order(Arel.sql("find_in_set(coupons.id, '#{set.reject(&:blank?).join(',')}')"))
  end

  def self.new_within_period(period = 7)
    where('coupons.start_date >= ?', Time.zone.now - period.days)
  end

  def self.active_in_days(n)
    status_active
      .where('coupons.start_date <= ?', Time.zone.now + n.days)
      .where('coupons.end_date >= ?', Time.zone.now + n.days)
  end

  def self.visible(allowed_ids = nil)
    return where(is_hidden: false) unless allowed_ids.present?
    where('coupons.is_hidden = false OR coupons.id in (?)', [*allowed_ids])
  end

  def self.expired(expired = true)
    if expired == true
      where('end_date IS NOT NULL')
        .where('end_date <= ?', Time.zone.now)
    else
      where('coupons.end_date >= ?', Time.zone.now)
    end
  end

  # inactive coupons are couons where the enddate is reached
  # but they should just show if the shop is active and not hidden
  def self.inactive
    includes(:shop)
      .where(shops: { status: 'active' })
      .where(status: 'active')
      .where('end_date IS NOT NULL')
      .where('end_date <= ?', Time.zone.now)
  end

  def self.savings_percentage
    where(savings_in: 'percent')
      .where('savings is not null AND savings != 0')
      .order(savings: :desc)
      .limit(1)
      .pluck(:savings)
      .first.to_i rescue nil
  end

  def self.top_position_savings_string(only_exclusive)
    first_coupon = top_position_coupon(only_exclusive)
    top_position_coupon.savings_in_string(false) if first_coupon.present?
  end

  def self.top_position_coupon(only_exclusive = false)
    where('savings != 0 and savings is not null and is_exclusive = 1 and savings_in = "percent"').first if only_exclusive
    where('savings != 0 and savings is not null').first
  end

  def savings_in_symbol
    return @savings_in_symbol if @savings_in_symbol.present?
    return '%' if savings_in == 'percent'
    return currency if currency.present?

    @savings_in_symbol = I18n.t(:SAVINGS_IN_CURRENCY, default: '$')
    @savings_in_symbol = Site.site_currency if @savings_in_symbol == '$'
    @savings_in_symbol
  end

  def savings_in_string(boldify = true)
    if boldify == true
      base = '<b>' + (savings.round.to_s rescue '0') + '</b>'
    else
      base = (savings.round.to_s rescue '0')
    end

    position = Setting::get('publisher_site.currency_symbol_position', default: 'right')
    if position == 'left' && savings_in_symbol != '%'
      (savings_in_symbol + base).html_safe
    else
      (base + savings_in_symbol).html_safe
    end
  end

  def add_click
    increment!(:clicks)
  end

  def add_vote(type)
    case type
    when 'negative'
      increment!(:negative_votes)
    else
      increment!(:positive_votes)
    end
  end

  def uniq_coupon_code(tracking_user)
    if tracking_user.present? && use_uniq_codes == true
      return next_uniq_code_or_fallback(tracking_user)
    end

    code
  end

  def is_new?
    days_new = Setting::get('publisher_site.days_coupon_is_new', default: 3).to_i
    coupon_date = start_date || created_at
    coupon_date > days_new.days.ago
  end

  def has_expired?
    end_date < Time.zone.now
  end

  def has_default_behaviour?
    shop.is_default_clickout || is_coupon?
  end

  def url_with_tracking_click(uniqid)
    url = ClickoutUrlService.new(self).replace_tracking_click(uniqid)
    url.match(/^(http|https):\/\//) ? url.html_safe : 'http://' + url.html_safe
  end

  def meta_title
    [shop.title, '-', title].join(' ')
  end

  def update_associated_active_coupons_counts
    shop.update_active_coupons_count
    categories.map(&:update_active_coupons_count)
  end

  def self.get_exclusive_coupons(quantity = 3, ids = [])
    if ids.present?
      where(id: ids).limit(quantity)
    else
      where(site_id: Site.current.id, status: 'active')
        .where(is_exclusive: 1)
        .where('logo IS NOT NULL AND TRIM(logo) <> ""')
        .where('end_date >= ?', Time.zone.now)
        .limit(quantity)
    end
  end

  def self.get_free_delivery_coupons(quantity = 3, ids = nil)
    if ids.present?
      where(id: ids).limit(quantity)
    else
      where(site_id: Site.current.id, status: 'active')
        .where(is_free_delivery: 1)
        .where('logo IS NOT NULL AND TRIM(logo) <> ""')
        .where('end_date >= ?', Time.zone.now)
        .limit(quantity)
    end
  end

  def self.get_new_coupons(quantity = 3, ids = nil)
    if ids.present?
      where(id: ids).limit(quantity)
    else
      where(site_id: Site.current.id, status: 'active')
        .where('start_date <= ?', Time.zone.now)
        .where('end_date >= ?', Time.zone.now)
        .where('logo IS NOT NULL AND TRIM(logo) <> ""')
        .limit(quantity)
    end
  end

  def self.get_top_coupons(quantity = 3, ids = nil)
    if ids.present?
      where(id: ids).limit(quantity)
    else
      where(site_id: Site.current.id, status: 'active')
        .where(is_top: 1)
        .where('logo IS NOT NULL AND TRIM(logo) <> ""')
        .where('end_date >= ?', Time.zone.now)
        .limit(quantity)
    end
  end

  def widget_or_shop_header
    return widget_header_image_url('_0x120') if widget_header_image_url.present?
    shop.header_image_url
  end

  def has_savings?
    savings.present? && savings.round > 0
  end

  def info_fields_hash
    fields = {}

    INFO_FIELDS.each do |f|
      next unless send(f).present?
      fields[f] = send(f)
    end
    fields
  end

  def coupon_or_shop_logo
    logo? ? logo_url : shop.logo_url
  end

  def is_coupon?
    coupon_type == 'coupon' && code.present?
  end

  def is_offer?
    !is_coupon?
  end

  def is_percentage?
    savings_in == 'percent'
  end

  def is_currency?
    savings_in == 'currency'
  end

  private

  def self.grid_filter_base(params)
    query = self
    query = query.where('coupons.id like ?', "%#{params[:id]}%") if params[:id].present?
    query = query.where(site_id: params[:site_id]) if params[:site_id].present?
    query = query.where(affiliate_network_id: params[:affiliate_network_id].reject(&:blank?)) if params[:affiliate_network_id].present? && params[:affiliate_network_id].reject(&:blank?).present?

    query = query.where(is_top: params[:is_top].to_s == 'true') if params[:is_top].present?
    query = query.where(is_exclusive: params[:is_exclusive].to_s == 'true') if params[:is_exclusive].present?
    query = query.where(is_free: params[:is_free].to_s == 'true') if params[:is_free].present?
    query = query.where(status: params[:status]) if params[:status].present?
    query = query.joins(:shop).where('shops.slug like ?', "%#{params[:shop_slug]}%" ) if params[:shop_slug].present?
    query = query.joins(:affiliate_network).where('affiliate_networks.slug like ?', "%#{params[:affiliate_network_slug]}%" ) if params[:affiliate_network_slug].present?

    query = query.where('coupons.title like ?', "%#{params[:title]}%") if params[:title].present?
    query = query.where('coupons.code like ?', "%#{params[:code]}%") if params[:code].present?

    query
  end

  def next_uniq_code_or_fallback(tracking_user)
    # in case a tracking user exists
    if tracking_user.present?

      # check if he had used a code for that coupon already
      used_code = coupon_codes.find_by_tracking_user_id(tracking_user.id)
      return used_code.code if used_code.present?

      # other wise find a new usable coupon code
      next_uniq_code = coupon_codes.next_usable

      # if any exists
      if next_uniq_code.present?
        # assign to the tracking user
        next_uniq_code.tracking_user = tracking_user
        # and mark as used

        return next_uniq_code.code if next_uniq_code.use!
      end
    end

    # otherwise return the fallback
    code
  end

  def prioritize_exclusive_coupons
    self.shop_list_priority = 1 if eligible_for_exclusive_prioritization?
  end

  def eligible_for_exclusive_prioritization?
    (is_exclusive? || is_editors_pick?) && shop_list_priority.to_i == 5
  end

  # replaces new_lines and carriage returns
  def sanitize_whitespaces
    [:title].each do |col|
      send("#{col}=", send(col).gsub(/(?:\n\r?|\r\n?)/, ''))
    end
  end

  def validate_subid_placeholder?
    affiliate_network.validate_subid rescue false
  end

  def subid_placeholder_present
    @placeholder ||= 'pctracking'
    return unless url.present? && !url.match(Regexp.new("#{@placeholder}|mt_tracking|pc_tracking")).present? # mt_tracking and pc_tracking was used in old urls

    errors.add :url, "needs to contain '#{@placeholder}' as defined in the affiliate network settings"
  end

  def coupon_type_valid
    errors.add :coupon_type, 'needs to be "coupon" or "offer"' unless %w[coupon offer].include?(coupon_type.to_s)
  end

  def coupon_or_offer
    errors.add :coupon_type, 'needs to be "Coupon" if a code is set' if coupon_type == 'offer' && code.present?
    errors.add :coupon_type, 'needs to be "Offer" if no code is set' if coupon_type == 'coupon' && !code.present?
  end

  def site_id_valid
    errors.add :site_id, 'cannot be different then the site_id of the shop' if shop.present? && site_id != shop.site_id
  end

  def shop_id_not_zero
    errors.add :shop_id, 'Slug doesnt match the site ID; Please select a shop from the list and save again!' if shop_id.to_i == 0
  end
end
