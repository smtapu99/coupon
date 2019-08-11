class Campaign < ApplicationRecord
  include ActsAsExportable
  include ActAsEdgeCachable
  include ActsAsSluggable
  include ActsAsCurrentEntity
  include ActsAsSiteable
  include ActsAsRoutesReloader
  include ActsAsStatusable
  has_statuses(
    active: 'active',
    blocked: 'blocked',
    gone: 'gone'
  )

  delegate :h1, :h2, :meta_robots, :meta_keywords, :meta_description, :meta_title, :content, :welcome_text, :meta_title_fallback, :head_scripts, :header_image, :mobile_header_image, :header_font_color, :countdown_date, :quicklinks, to: :html_document, prefix: true, allow_nil: true

  delegate :name, to: :parent, prefix: true, allow_nil: true
  delegate :title, to: :shop, prefix: true, allow_nil: true

  # Relations
  belongs_to :shop
  belongs_to :parent, class_name: 'Campaign'

  has_one :site_user, through: :site
  has_one :html_document, as: :htmlable, dependent: :destroy
  has_one :setting, dependent: :destroy

  has_many :sub_campaigns, class_name: 'Campaign', foreign_key: 'parent_id'
  has_many :relations_to, as: :relation_from, dependent: :destroy, class_name: 'Relation', validate: false
  has_many :related_shops, through: :relations_to, class_name: 'Shop', source: :relation_to, source_type: 'Shop', validate: false

  has_many :campaigns_coupons, dependent: :destroy
  has_many :coupons, through: :campaigns_coupons

  accepts_nested_attributes_for :html_document, update_only: true
  accepts_nested_attributes_for :setting

  # Validation
  validate :parent_campaign_validation
  validate :sem_template_validation
  validate :root_campaign_validation
  validate :priority_coupon_ids_count
  validates_presence_of :name
  validates_uniqueness_of :name, scope: [:site_id, :shop_id]
  validates_uniqueness_of :slug, scope: [:site_id, :shop_id]

  scope :indexed, -> { includes(:html_document).references(:html_document).where.not("html_documents.meta_robots like '%noindex%'") }
  scope :active, -> { where("campaigns.status = 'active' AND (campaigns.start_date IS NULL OR campaigns.start_date <= ?) AND (campaigns.end_date IS NULL OR campaigns.end_date >= ?)", Time.zone.now, Time.zone.now) }
  scope :without_sem, -> { where.not(template: 'sem') }

  # Site Settings accessible with prefix setting_site_
  ['show_footer', 'show_header_logo_area', 'custom_head_scripts'].each do |feature|
    define_method("setting_site_#{feature}") do
      setting.get("publisher_site.#{feature}", campaign_id: id) if setting.present?
    end
  end

  ['show_featured_images_before_coupons'].each do |feature|
    define_method("setting_widget_ranking_#{feature}") do
      setting.get("widget_ranking.#{feature}", campaign_id: id) if setting.present?
    end
  end

  # # used for migration with zero downtime.
  # # disables writes to the rejected colums
  def self.columns
    super.reject do |column|
      [
        'blocked_by_relation',
        'show_nav_link',
        'tag_string'
      ].include?(column.name.to_s)
    end
  end

  def self.order_by_set(set, root_campaigns_first = false)
    if set.present?
      if root_campaigns_first
        return order(Arel.sql("is_root_campaign = 1 DESC, find_in_set(campaigns.id, '#{set.reverse.reject(&:blank?).join(',')}') DESC, campaigns.created_at DESC"))
      end

      order(Arel.sql("find_in_set(campaigns.id, '#{set.reverse.reject(&:blank?).join(',')}') DESC, created_at DESC"))
    else
      order("campaigns.created_at DESC")
    end
  end

  def self.grid_filter(params)
    query = self
    query = query.where(site_id: params[:site_id])

    if params[:parent].present?
      parents = query.where('name like ?', "%#{params[:parent]}%")
      query = query.where(parent_id: parents.map(&:id)) if parents.present?
    end

    query = query.where(id: params[:id]) if params[:id].present?
    query = query.where(is_root_campaign: params[:is_root_campaign].to_s == 'true') if params[:is_root_campaign].present?
    query = query.where(status: params[:status]) if params[:status].present?
    query = query.where('name like ?', "%#{params[:name]}%") if params[:name].present?
    query = query.where('slug like ?', "%#{params[:slug]}%") if params[:slug].present?
    query = query.joins(:shop).where('shops.title like ?', "%#{params[:shop]}%" ) if params[:shop].present?
    query = query.where('blog_feed_url like ?', "%#{params[:blog_feed_url]}%") if params[:blog_feed_url].present?

    query = query.where('start_date >= ?',  string_to_utc_time('start_date_from', params['start_date_from'])) if params['start_date_from'].present?
    query = query.where('start_date <= ?', string_to_utc_time('start_date_to', params['start_date_to'])) if params['start_date_to'].present?

    query = query.where('end_date >= ?', string_to_utc_time('end_date_from', params['end_date_from'])) if params['end_date_from'].present?
    query = query.where('end_date <= ?', string_to_utc_time('end_date_to', params['end_date_to'])) if params['end_date_to'].present?

    query
  end

  # Returns allowed import parameter
  #
  # @return [Array] allowed import parameter
  def self.allowed_import_params
    [
      'Site ID',
      'Parent ID',
      'Coupon Filter Headline',
      'Priority Coupon IDs',
      'End Date',
      'H1 First Line',
      'H1 Second Line',
      'Name',
      'Nav Title',
      'SEO Text',
      'SEO Text Headline',
      'Shop',
      'Slug',
      'Start Date',
      'Status',
      'Is Root Campaign',
      'SEM Page Logo URL',
      'SEM Page Background URL',
      'Template'
    ]
  end

  def self.export(params)
    if params[:site_ids].present? && params[:site_ids].reject(&:blank?).present?
      site_ids = params[:site_ids].reject(&:blank?)
    else
      site_ids = []
    end

    query = self
    query = where(site_id: site_ids) if site_ids.present?

    sanitized_params = params.select { |k| ['slugs', 'parent_ids'].include? k }.to_h
    sanitized_params.merge!(sanitized_params) { |_, v| v.split(',') }

    query = query.includes(:html_document).references(:html_document)

    query = query.where(slug: sanitized_params[:slugs]) if sanitized_params[:slugs].present?
    query = query.where(parent_id: sanitized_params[:parent_ids]) if sanitized_params[:parent_ids].present?

    query = query.where(template: params[:templates]) if params[:templates].present?
    query = query.where(status: params[:status].reject(&:blank?)) if params[:status].reject(&:blank?).present?
    query = query.where('campaigns.created_at >= ?', concat_datetime('created_at_from', params)) if params['created_at_from(1i)'].present?
    query = query.where('campaigns.created_at <= ?', concat_datetime('created_at_to', params))   if params['created_at_to(1i)'].present?

    query
  end

  def self.to_export_xls
    xls = Axlsx::Package.new
    xls.workbook do |wb|
      wb.add_worksheet(name: "campaigns_#{Time.now.to_date}") do |sheet|
        sheet.add_row Shop::CSV_EXPORT_COLUMN_HEADERS[:campaign].values

        all.each do |campaign|
          sheet.add_row campaign.csv_mapped_attributes
        end
      end
    end
    xls
  end

  def self.campaigns_for_sitemap(main_campaign_ids = [])
    query = active.without_sem.indexed
    if main_campaign_ids.present?
      query = query.order_by_set(main_campaign_ids.reject(&:blank?).reject(&:zero?), true)
    end
    query
  end

  def sitemap_priority
    return '0.6' if main_campaign_ids.include?(id) || is_root_campaign?
    '0.3'
  end

  def nav_title_or_name
    nav_title.present? ? nav_title : name
  end

  def id_and_nav_title_or_name
    "#{id}: #{nav_title_or_name}"
  end

  def parent_slug
    parent.slug if parent.present?
  end

  def shop_slug
    shop.slug if shop.present?
  end

  def shop_title
    shop.title if shop.present?
  end

  def parent_or_shop_present?
    parent.present? || shop.present?
  end

  def has_inactive_parent?
    (parent.present? && !parent.is_active?) || (shop.present? && !shop.is_active?)
  end

  def themed_fallback_into_grid?
    is_themed? && Option.custom_layout.present?
  end

  def category
    shop.shop_categories.first if shop_id
  end

  def is_themed?
    template.start_with?('themed')
  end

  def is_grid?
    template == 'grid'
  end

  def active_coupons_count
    shop.present? ? "#{shop.active_coupons_count}" : ''
  end

  def priority_coupon_ids_array
    return [] unless priority_coupon_ids.present?
    priority_coupon_ids.delete(' ').split(',').map(&:to_i)
  end

  def id_and_name
    "#{id} - #{name}"
  end

  private

  def main_campaign_ids
    @main_campaign_ids ||= Setting::get('menu.main_campaign_ids', default: []).map(&:to_i)
  end

  def priority_coupon_ids_count
    errors.add(:priority_coupon_ids, 'cannot be more then 48') if priority_coupon_ids_array.count > 48
  end

  def root_campaign_validation
    errors.add(:shop_id, 'cannot be set if campaign is Root Campaign') if shop_id.present? && is_root_campaign?
  end

  def sem_template_validation
    errors.add(:shop_id, 'cannot be set if campaign template is SEM') if shop_id.present? && template.to_s == 'sem'
    errors.add(:parent_id, 'cannot be set if campaign template is SEM') if parent_id.present? && template.to_s == 'sem'
  end

  def parent_campaign_validation
    errors.add(:parent_id, 'cannot be id of campaign itself') if !new_record? && parent_id == id
    errors.add(:parent_id, 'cannot be subpage of a parent that is already a subpage itself') if parent.present? && (parent.shop_id.present? || parent.parent_id.present?)
    errors.add(:parent_id, 'cannot be set if shop_id is set. Campaign can only be subpage of either shop or campaign') if parent_id.present? && shop_id.present?
    errors.add(:general, 'cannot be marked as subpage. Campaign has subpages already') if (parent_id.present? || shop_id.present?) && sub_campaigns.present?
  end
end
