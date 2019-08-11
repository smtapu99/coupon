class Shop < ApplicationRecord
  include ActsAsExportable
  include ActAsEdgeCachable
  include ClearsCustomCaches
  include ActsAsSiteable
  include ActsAsSluggable
  include ActsAsAlgoliaSearchable
  include ActsAsVotable
  include ActsAsStatusable
  has_statuses(
     active: 'active',
     pending: 'pending',
     blocked: 'blocked',
     gone: 'gone'
  )

  attr_accessor :l, :lc, :hi, :active_coupons_count_operator, :click_sum, :site_ids, :main_category_slug

  serialize :info_delivery_methods, Array
  serialize :info_payment_methods, Array

  PRIORITY_COUNT = 4

  delegate :h1, :h2, :meta_robots, :meta_keywords, :meta_description, :meta_title, :content, :welcome_text, :meta_title_fallback, :head_scripts, to: :html_document, prefix: true, allow_nil: true
  delegate :slug, to: :prefered_affiliate_network, prefix: true, allow_nil: true

  mount_uploader :logo, Admin::ShopUploader if (ENV['RAKE_IMPORT'].nil?)
  mount_uploader :header_image, Admin::ShopUploader if (ENV['RAKE_IMPORT'].nil?)
  mount_uploader :first_coupon_image, Admin::ShopUploader if (ENV['RAKE_IMPORT'].nil?)

  # Associations
  belongs_to :site
  belongs_to :global, -> { where(model_type: 'Shop') }
  belongs_to :prefered_affiliate_network, class_name: 'AffiliateNetwork'
  belongs_to :person_in_charge, class_name: 'User'

  has_many :coupons
  has_many :active_coupons, -> { merge(Coupon.active) }, class_name: 'Coupon'
  has_many :categories, -> { distinct }, through: :coupons
  has_many :affiliate_networks, -> { distinct }, through: :coupons
  has_many :shop_category_relations, class_name: 'ShopCategory'
  has_many :shop_categories, through: :shop_category_relations, source: :category
  has_many :campaigns
  has_many :relations_to, as: :relation_from, dependent: :destroy, class_name: 'Relation'
  has_many :related_categories, through: :relations_to, class_name: 'Category', source: :relation_to, source_type: 'Category'
  has_many :related_shops, through: :relations_to, class_name: 'Shop', source: :relation_to, source_type: 'Shop'
  has_many :related_campaigns, through: :relations_to, class_name: 'Campaign', source: :relation_to, source_type: 'Campaign'

  has_many :newsletter_subscriber_shops
  has_many :newsletter_subscribers, through: :newsletter_subscriber_shops

  has_one :html_document, as: :htmlable, dependent: :destroy
  has_many :banner_locations, as: :bannerable, dependent: :destroy

  accepts_nested_attributes_for :html_document, update_only: true

  validates :title, presence: true
  validates_presence_of :fallback_url
  validates_presence_of :global_id
  validates :fallback_url, url: true
  validates_uniqueness_of :title, scope: :site_id
  validates :tier_group, :numericality => { :greater_than_or_equal => 1, :less_than_or_equal_to => 4 }
  validate :valid_category
  validates :clickout_value, :numericality => { :greater_than_or_equal => 0, :less_than_or_equal_to => 999 }

  before_validation :sanitize_urls
  before_validation :sanitize_title

  after_update :clear_relevant_categories_cache

  scope :shops_by_site, ->(id) { id.present? ? where(site_id: id) : self }
  scope :active_and_visible, -> { where(status: 'active', is_hidden: false) }
  scope :indexed, -> { includes(:html_document).references(:html_document).where("meta_robots IS NULL OR meta_robots NOT LIKE '%noindex%'") }
  scope :without_shop, -> (shop) {
    where.not(id: shop)
  }
  scope :join_active_coupons_in_days, ->(n) {
    joins(:coupons).merge(::Coupon.active_in_days(n)).group('shops.id')
  }

  # used for migration with zero downtime. disables writes to the rejected colums
  def self.columns
    super.reject { |column| ['priority', 'is_featured', 'shop_slider_position'].include?(column.name) }
  end

  def self.order_by_set(set)
    if set.present?
      order(Arel.sql("find_in_set(shops.id, '#{set.reject(&:blank?).join(',')}')"))
    else
      order("shops.id DESC")
    end
  end

  # CA-1006
  # Calculates the priority of the shop... the higher the better
  #
  # (clickout_value || 0.00001) x ((count of subpages || 1) x active_coupons_count x (number_of_prios / prio)
  def self.calculate_priorities(sites = nil)
    transaction do
      raise ActiveRecord::Rollback unless shops_by_site(sites).update_all(priority_query)
    end
  end

  def calculate_priority
    transaction do
      raise ActiveRecord::Rollback unless self.class.where(id: id).update_all(self.class.priority_query)
    end
  end

  def self.priority_query
    "
      priority_score = ROUND(IFNULL((
        (CASE WHEN clickout_value = 0 THEN 0.00001 ELSE shops.clickout_value END)
        * (CASE WHEN @subpage_count = (Select count(*) from campaigns where shop_id = shops.id) AND @subpage_count > 0 THEN @subpage_count ELSE 1 END)
        * active_coupons_count
        * (#{Shop::PRIORITY_COUNT} / shops.tier_group)), 0), 5)
    "
  end

  def self.search_by_title(query, limit = 3)
    where("LOWER(shops.title) like ?", query.downcase + '%')
     .order('priority_score DESC')
     .limit(limit)
  end

  def self.by_tier_group(tier_score)
    where(tier_group: tier_score)
  end

  def self.active_coupons_filter(params)
    params = ActiveSupport::HashWithIndifferentAccess.new(params)
    query = grid_filter_base(params)
    query = query.where(active_coupons_count: params[:today]) if params[:today].present?
    query = query.from(query.join_active_coupons_in_days(3).having("COUNT(coupons.id) = ?", params[:"3_days"]), 'shops') if params[:"3_days"].present?
    query = query.from(query.join_active_coupons_in_days(7).having("COUNT(coupons.id) = ?", params[:"7_days"]), 'shops') if params[:"7_days"].present?
    query
  end

  def self.grid_filter(params)
    params = ActiveSupport::HashWithIndifferentAccess.new(params)
    query = grid_filter_base(params)
  end

  def self.export(params)
    site_ids = params[:site_ids].present? ? [*params[:site_ids]].map(&:to_s).reject(&:empty?) : []

    query = self
    query = where(site_id: site_ids) if site_ids.present?
    query = query.where(id: params[:shop_ids]) if params[:shop_ids].present?
    query = query.includes(:html_document).references(:html_document)
    query = query.where(status: params[:status].reject(&:blank?))         if params[:status].present? && params[:status].reject(&:blank?).present?
    query = query.where(is_hidden: params[:is_hidden])                    if params[:is_hidden].present? && params[:is_hidden].present?
    query = query.where(tier_group: params[:tier_group].reject(&:blank?)) if params[:tier_group].present? && params[:tier_group].reject(&:blank?).present?
    query = query.where(person_in_charge_id: params[:person_in_charge_id]) if params[:person_in_charge_id].present?

    query = query.where('shops.created_at >= ?', concat_datetime('created_at_from', params)) if params['created_at_from(1i)'].present?
    query = query.where('shops.created_at <= ?', concat_datetime('created_at_to', params))   if params['created_at_to(1i)'].present?

    query = query.where("shops.active_coupons_count #{params[:active_coupons_count_operator]} ?", params[:active_coupons_count]) if params[:active_coupons_count].present?

    query
  end

  def self.to_export_xls
    xls = Axlsx::Package.new
    xls.workbook do |wb|
      wb.add_worksheet(name: "shops_#{Time.now.to_date}") do |sheet|
        sheet.add_row Shop::CSV_EXPORT_COLUMN_HEADERS[:shop].values

        all.each do |shop|
          sheet.add_row shop.csv_mapped_attributes
        end
      end
    end
    xls
  end

  def self.to_export_csv(options = {})
    CSV.generate(options) do |csv|
      csv << Shop::CSV_EXPORT_COLUMN_HEADERS[:shop].values
      all.each do |shop|
        csv << shop.csv_mapped_attributes
      end
    end
  end

  # Gets shop status statistic as hash
  #
  # @return [hash]
  # @example e.g \\{"active" => 100, "blocked" => 6, "pending" => 50\}
  def self.stats
    defaults = { 'active' => 0, 'blocked' => 0, 'pending' => 0 }
    allowed_sites = Site.current ? Site.current.id : User.current.get_current_user_sites
    stats = where(site_id: allowed_sites).group(:status).count
    defaults.merge(stats)
  end

  def self.order_by_priority
    order('shops.priority_score DESC')
  end

  def self.order_by_most_clicked
    select('shops.*, sum(coupons.clicks) as click_sum').joins(:coupons).group('shops.id').order('click_sum DESC')
  end

  def self.by_type(type)
    case type.to_s
    when 'most_clicked'
      order_by_most_clicked
    else
      where("shops.is_#{type} = ?", 1)
    end
  end

  # def categories
  #   Rails.cache.fetch([self.site_id, 'categories']) do
  #     _categories = []
  #     self.coupons.includes(:categories).each do |c|
  #       _categories + c.categories
  #     end
  #     _categories
  #   end
  # end

  # compute pending status from blocked and active status
  # @param  blocked_active_sum [Integer] sum of active and blocked status
  #
  # @return [Integer] amount of pending status
  def self.get_statistic_pending(blocked_active_sum)
    if Site.current
      sum_shops = Site.current.shops.count
    else
      sum_shops = Shop.count
    end

    if blocked_active_sum.blank?
      sum_shops
    else
      (sum_shops - blocked_active_sum)
    end
  end

  def self.active
    where(status: 'active')
  end

  def self.hidden
    where(is_hidden: true)
  end

  def self.visible
    where(is_hidden: false)
  end

  def self.with_logo
    where('shops.logo IS NOT NULL')
  end

  def self.with_pagination(page_size = 5)
    where('active_coupons_count > ?', page_size)
  end

  def self.without_pagination(page_size = 5)
    where('active_coupons_count <= ?', page_size)
  end

  def top_coupon_logo
    coupon = coupons.active.with_logo.first
    coupon.present? ? coupon.logo_url : logo_url
  end

  def self.get_by_role
    if Site.current
      Site.current.shops
    else
      User.current.shops
    end
  end

  def self.with_active_coupons
    where('shops.active_coupons_count > 0')
  end

  def self.with_no_header
    where('header_image IS NULL')
  end

  def self.has_pagination
    page_size = site.setting.get('publisher_site.coupons_per_shop_page', default: 5)
    active_coupons_count > page_size
  end

  def click_sum
    coupons.sum(:clicks)
  end

  def relevant_categories
    return shop_categories if shop_categories.present?

    coupon_category = CouponCategory.where(coupon_id: coupon_ids).select('category_id').group(:category_id).order(Arel.sql('count(category_id) DESC')).first

    if coupon_category.present?
      return [coupon_category.category]
    end

    []
  end

  def alt_text_or_title
    logo_alt_text.present? ? logo_alt_text : title
  end

  def anchor_text_or_title
    anchor_text.present? ? anchor_text : title
  end

  def site_id_and_title
    if Site.current
      title
    else
      "#{site_id} - #{title}"
    end
  end

  def title_and_site_name
    if Site.current
      title
    else
      "#{title} - #{site.name}"
    end
  end

  def update_active_coupons_count
    update_column(:active_coupons_count, coupons.active.count)
  end

  def sanitize_urls
    self.url = smart_add_url_protocol url
    self.fallback_url = smart_add_url_protocol fallback_url
  end

  def sanitize_title
    self.title = title.strip if title.present?
  end

  def smart_add_url_protocol url
    return if url.blank?

    unless url[/\Ahttp:\/\//] || url[/\Ahttps:\/\//]
      return "http://#{url}"
    end
    url
  end

  # Returns allowed import parameter
  #
  # @return [Array] allowed import parameter
  def self.allowed_import_params
    params = [
      'Status',
      'Global ID',
      'Shop Title',
      'Anchor Text',
      'Slug',
      'Fallback URL',
      'Link Title',
      'Description',
      'Header Image',
      'First Coupon Image',
      'Logo',
      'Logo Alt',
      'Logo Title Text',
      'Display Description On Shop Page',
      'Display Logo On Coupons',
      'Prefered Affiliate Network Slug',
      'Is Hidden',
      'Is Top',
      'Traffic',
      'Person In Charge',
      'Category IDs',
      'Clickout Value',
      'Tier Group',
      'Is Default Clickout',
      'Is Direct Clickout',
      'Site ID',
      'Address',
      'Phone',
      'Free Shipping',
      'Payment Methods',
      'Delivery Methods'
    ]
  end

  def savings_percentage
    coupons.active.visible.where(savings_in: 'percent').where('savings is not null AND savings != 0').order(savings: :desc).limit(1).pluck(:savings).first.to_i rescue nil
  end

  def is_active_and_visible?
    status == 'active' && is_hidden == false
  end

  def sitemap_priority
    case tier_group
    when 1
      '0.8'
    when 2
      '0.6'
    when 3
      '0.4'
    else
      '0.3'
    end
  end

  def sitemap_changefreq
    return 'hourly' if tier_group == 1
    'daily'
  end

  def has_valid_payment_methods?
    payment_methods = info_payment_methods.reject(&:blank?)
    payment_methods.present? && (payment_methods.map(&:downcase) - Option::get_select_options(:payment_methods).values.map(&:downcase)).empty?
  end

  def has_valid_delivery_methods?
    delivery_methods = info_delivery_methods.reject(&:blank?)
    delivery_methods.present? && (delivery_methods.map(&:downcase) - Option::get_select_options(:delivery_methods).values.map(&:downcase)).empty?
  end

  def api_category_slug
    main_category_slug || shop_categories.try(:first).try(:slug)
  end

  private

  def self.grid_filter_base(params)
    query = self
    query = query.where(site_id: params[:site_id]) if params[:site_id].present?
    query = query.where('shops.title like ?', "%#{params[:title]}%") if params[:title].present?
    query = query.where('shops.slug like ?', "%#{params[:slug]}%") if params[:slug].present?
    query = query.where(id: params[:id]) if params[:id].present?
    query = query.where(tier_group: params[:tier_group]) if params[:tier_group].present?
    query = query.where(status: params[:status]) if params[:status].present?
    query = query.where(is_hidden: params[:is_hidden].to_s == 'true') if params[:is_hidden].present?
    query = query.where(is_top: params[:is_top].to_s == 'true') if params[:is_top].present?
    query
  end

  def clear_relevant_categories_cache
    Rails.cache.delete([site_id, 'rel_cat', id])
  end

  def valid_category
    # check if the array of category site_ids contains others then this shops site_id
    errors.add :shop_category_ids, 'cannot contain category ids from other sites' if shop_categories.map(&:site_id).reject{|id| id == self.site_id}.size > 0
  end
end
