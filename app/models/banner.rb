class Banner < ApplicationRecord
  serialize :value, Hash
  serialize :excluded_shop_ids, Array

  validates :site, :start_date, :end_date, presence: true
  validate :end_date_possible

  belongs_to :site
  has_many :banner_locations, dependent: :destroy
  has_many :categories, -> { where(banner_locations: { bannerable_type: 'Category' }) }, through: :banner_locations, source: :bannerable, source_type: 'Category'
  has_many :shops, -> { where(banner_locations: { bannerable_type: 'Shop' }) }, through: :banner_locations, source: :bannerable, source_type: 'Shop'

  scope :by_shop, ->(shop_id) { where('banner_locations.bannerable_id = ? AND bannerable_type = "Shop"', shop_id) }
  scope :by_category, ->(category_id) { where('banner_locations.bannerable_id = ? AND bannerable_type = "Category"', category_id) }
  scope :show_in_shops, ->(show_in_shops) { where('banners.show_in_shops = ?', show_in_shops) }
  scope :without_locations, -> { where('banner_locations.id IS NULL') }
  scope :home_page_banner, -> { where(show_on_home_page: true) }

  scope :base_type_query, ->(type, allow_default=true) {
    join_type = allow_default == false ? 'INNER JOIN' : 'LEFT JOIN'

    joins(join_type + ' banner_locations on banner_locations.banner_id = banners.id')
      .where(banner_type: type)
      .where(status: :active)
      .where('start_date IS NULL OR start_date <= NOW()')
      .where('end_date IS NULL OR end_date >= NOW()')
      .order('end_date ASC')
  }

  def self.serialized_attr_accessor(*args)
    args.each do |method_name|
      eval "
        def #{method_name}
          (self.value || {})[:#{method_name}]
        end
        def #{method_name}=(value)
          self.value ||= {}
          self.value[:#{method_name}] = value
        end
      "
    end
  end

  serialized_attr_accessor :content,
    :theme,
    :caption_heading,
    :caption_body,
    :button_text,
    :target_url,
    :countdown_date,
    :image_url,
    :logo_url,
    :font_color,
    :cta_background,
    :cta_color,
    :href,
    :alt,
    :is_external_url,
    :animate,
    :attach_newsletter_popup

  # fetches banners with locations for shop_id or category_id
  # returns the default banner if no location is found
  # when shop_id and category_id is given and no shop location is found
  # then we only show category locations if banners.show_in_shops = true
  # allow_default option can be used to avoid fallback to default
  # order:
  # shop_id, category_id, no banner location, end_date
  def self.by_type_shop_and_category(type, opts={})
    allow_default = opts[:allow_default] === false ? false : true # if nil true

    return base_type_query(type, allow_default).where(show_on_home_page: true).first if opts[:show_on_home_page] == true

    default_banner = base_type_query(type, allow_default).without_locations
    return first_allowed(default_banner, opts[:shop_id]) unless opts[:shop_id].present? || opts[:category_id].present?

    banners = base_type_query(type, allow_default).by_shop_or_category(opts).reorder_by_banner_priority(opts[:shop_id])
    if banner = first_allowed(banners, opts[:shop_id]) and banner.present?
      return banner
    end

    first_allowed(default_banner, opts[:shop_id])
  end

  def self.by_shop_or_category(opts={})
    if opts[:shop_id].present? && opts[:category_id].present?
      by_shop(opts[:shop_id]).or(by_category(opts[:category_id]).show_in_shops(true))
    elsif opts[:shop_id].present?
      by_shop(opts[:shop_id])
    elsif opts[:category_id].present?
      by_category(opts[:category_id])
    else
      all
    end
  end

  def self.reorder_by_banner_priority(shop_id=nil)
    sql = 'CASE WHEN banner_locations.id IS NOT NULL THEN 1 ELSE 0 END DESC,'
    sql += ' CASE WHEN bannerable_type="Shop" AND bannerable_id="' + shop_id.to_s + '" THEN 1 ELSE 0 END DESC,' if shop_id.present?
    sql += ' CASE WHEN banners.end_date IS NOT NULL THEN 1 ELSE 0 END DESC,'
    sql += ' end_date ASC'

    reorder(Arel.sql(sql))
  end

  def self.first_allowed(banners, shop_id=nil)
    return banners.first if shop_id.nil?
    banners.find { |banner| !banner.excluded_shop_ids.map(&:to_s).include?(shop_id.to_s) }
  end

  def start_time
    "#{start_date.to_date.to_s}T00:00:00"
  end

  def end_time
    "#{end_date.to_date.to_s}T23:59:59"
  end

  def self.grid_filter(params)
    params = ActiveSupport::HashWithIndifferentAccess.new(params)

    query = all
    query = query.where(id: params[:id]) if params[:id].present?
    query = query.where("name like ?", "%#{params[:name]}%") if params[:name].present?
    query = query.where("value like ?", "%theme:%#{params[:theme]}%") if params[:theme].present?
    query = query.where(status: params[:status]) if params[:status].present?
    query = query.where(site_id: params[:site_id]) if params[:site_id].present?
    query = query.where(banner_type: params[:banner_type]) if params[:banner_type].present?

    query = query.where('start_date >= ?', string_to_utc_time('start_date_from', params[:start_date_from])) if params[:start_date_from].present?
    query = query.where('start_date <= ?', string_to_utc_time('start_date_to', params[:start_date_to])) if params[:start_date_to].present?
    query = query.where('end_date >= ?', string_to_utc_time('end_date_from', params[:end_date_from])) if params[:end_date_from].present?
    query = query.where('end_date <= ?', string_to_utc_time('end_date_to', params[:end_date_to])) if params[:end_date_to].present?
    query
  end

  private

  def end_date_possible
    if start_date.present? && end_date.present? && end_date < start_date
      errors.add(:end_date, 'cannot be before start_date')
    end
  end
end
