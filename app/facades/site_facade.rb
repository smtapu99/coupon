class SiteFacade

  attr_reader :site

  def initialize(site)
    raise 'Invalid Site' unless site.instance_of? Site
    @site = site
  end

  def id
    @site.id
  end

  def locale
    @site.country.locale
  end

  def relevant_categories=(cat)
    @site.relevant_categories = cat
  end

  def relevant_categories
    @site.relevant_categories
  end

  def visible_coupons=(coupons)
    @site.visible_coupons = coupons
  end

  def visible_coupons
    @site.visible_coupons
  end

  def visible_coupon_ids
    if visible_coupons.present?
      visible_coupons.map(&:id)
    else
      []
    end
  end

  def home_breadcrumb_name
    @home_breadcrumb_name ||= Setting.get('publisher_site.home_breadcrumb_name', default: site.hostname)
  end

  def image_setting
    site.image_setting
  end

  def favicon_asset_path(path)
    site.favicon_asset_path(path)
  end

  def shop_banner(opts = {})
    @shop_banner ||= site.banners.by_type_shop_and_category('shop_banner', shop_id: opts[:shop_id], category_id: opts[:category_id])
  end

  def sidebar_banner(opts = {})
    is_shops_show = opts[:is_shops_show] === true ? true : false
    @sidebar_banner ||= site.banners.by_type_shop_and_category('sidebar_banner', shop_id: opts[:shop_id], category_id: opts[:category_id], allow_default: !is_shops_show)
  end

  def sticky_banner(opts = {})
    @sticky_banner ||= site.banners.by_type_shop_and_category('sticky_banner', shop_id: opts[:shop_id], category_id: opts[:category_id], show_on_home_page: opts[:show_on_home_page])
  end

  def bucket_asset_path
    @bucket_asset_path ||= @site.asset_hostname_for_fog + '/assets/' + @site.host_to_file_name
  end

  def campaign_coupons(campaign)
    priority_ids = campaign.priority_coupon_ids.to_s.delete(' ').split(',')

    campaign.coupons
      .active
      .joins(:shop)
      .includes(:shop)
      .visible(priority_ids)
      .order_by_campaign_priority(priority_ids)
  end

  def tags
    @site.tags
  end

  def coupons
    active_coupons_query
  end

  def coupon(id)
    coupons.where(id: id).first
  end

  def featured_shops_home(limit = 11)
    return @featured_shops_home if @featured_shops_home.present?

    featured_shop_ids = Setting::get('publisher_site.featured_shop_ids', default: []).reject(&:blank?)
    return [] if featured_shop_ids.empty?

    @featured_shops = Shop.where(id: featured_shop_ids.map(&:to_i))
      .order_by_set(featured_shop_ids)
      .visible.with_logo
      .limit(limit)
  end

  def featured_shops_home_fallback(limit = 11, exclude_ids = [])
    query = shops.visible.with_logo
     .order(is_top: :desc)
     .limit(limit)

    query = query.where('id not in (?)', exclude_ids) if exclude_ids.present?
    query
  end

  # 424-category-page-show-only-tear-1-tear-2-featured-shops
  def featured_shops_by_category(category, limit = 6)
    category.related_shops.active.limit(limit).order(tier_group: :asc)
  end

  def inactive_coupons
    inactive_coupons_query
  end

  def weekly_coupons_count
    Rails.cache.fetch([@site.id, 'weekly_coupons_count']) do
      active_coupons_query.where(created_at: Time.zone.now..1.week.ago).count
    end
  end

  def shops
    active_shops_query
  end

  def popular_and_related_shops(shop, category)
    total_count = site.shops.count
    order = category.order_position.to_i
    max_order = site.categories.maximum(:order_position).to_i
    seventh = (total_count * 0.07).ceil
    tenth = (total_count * 0.1).ceil

    chain = [*(order..max_order), *(0..order-1)]

    cats = [category, category.parent, *category.sub_categories.active].reject(&:blank?)
    cats += categories.main_category
      .where(order_position: chain)
      .where.not(id: cats.map(&:id))
      .order(Arel.sql("FIND_IN_SET(categories.order_position, '#{chain.join(',')}')"))

    popular_shops  = related_shops_by_categories(cats, tier_group: 1, limit: seventh, excluded_ids: [shop.id])
    related_shops  = related_shops_by_categories(cats, tier_group: shop.tier_group, limit: tenth, excluded_ids: [shop.id, *popular_shops.pluck(:id)])
    related_shops += related_shops_by_categories(cats, tier_group: shop.tier_group + 1, limit: 5, excluded_ids: [shop.id]) if shop.tier_group < 4
    { popular: popular_shops, related: related_shops }
  end

  def related_shops_by_categories(cats, opts = {})
    return [] unless cats.present?
    opts[:excluded_ids] ||= []
    opts[:limit] ||= 5

    i = 0
    result = []
    cats = [*cats]

    while i < cats.count && result.count < opts[:limit]
      query = cats[i]
        .shops_by_shop_category
        .active
        .reorder(tier_group: :asc, priority_score: :desc)
        .select('shops.id', 'shops.title', 'shops.logo', 'shops.logo_alt_text', :anchor_text, :slug)

      query = query.by_tier_group(opts[:tier_group]) if opts[:tier_group].present?
      query = query.where('shop_categories.shop_id NOT IN (?)', opts[:excluded_ids]) if opts[:excluded_ids].present?
      query = query.limit(opts[:limit]) if opts[:limit].present?
      result += query
      i += 1
    end
    result = result.flatten.uniq
    result = result.take(opts[:limit]) if opts[:limit].present?
    result
  end

  def search_shop_by_title(title, limit = 3)
    shops.visible.search_by_title title, limit
  end

  # returns an hash with shop id and contatenated category slugs, dont put too much where clauses here as it should be fast
  # and just serves as helper to fetch the slugs for a shop fastly, e.g. @shop_category_slugs[shop.id]
  #
  # @return [Hash] Hash with site_id
  def shop_category_slugs
    @shop_category_slugs = Rails.cache.fetch([@site.id, 'shop_category_slugs']) do
      sql = "SELECT DISTINCT `shops`.id as id, GROUP_CONCAT( DISTINCT categories.slug ORDER BY categories.slug ASC ) as slugs
            FROM  `categories`
            INNER JOIN  `coupon_categories` ON  `categories`.`id` =  `coupon_categories`.`category_id`
            INNER JOIN  `coupons` ON  `coupon_categories`.`coupon_id` =  `coupons`.`id`
            INNER JOIN shops ON shops.id = coupons.shop_id
            WHERE coupons.site_id = #{@site.id} AND shops.status = 'active' AND coupons.status = 'active'
            GROUP BY shops.id"

      result = ActiveRecord::Base.connection.execute(sql)
      shop_category_slugs = {}
      result.each(as: :hash) do |row|
        shop_category_slugs[row['id']] = row['slugs']
      end
      shop_category_slugs
    end
  end

  def categories
    active_categories_query
  end

  def subcategories(category)
    category.sub_categories.active
  end

  def category_siblings(category)
    return [] unless category.parent.present?
    category.parent.sub_categories.active
  end

  def nav_categories
    return @nav_categories if @nav_categories.present?

    nav_category_ids = Setting::get('menu.navigation_category_ids', default: []).reject(&:blank?)
    return [] unless nav_category_ids.present?

    @nav_categories = categories
      .where(id: nav_category_ids)
      .order_by_set(nav_category_ids)
  end

  def campaigns_for_sitemap
    main_campaign_ids = Setting::get('menu.main_campaign_ids', default: []).map(&:to_i)
    site.campaigns.campaigns_for_sitemap(main_campaign_ids)
  end

  def nav_campaigns
    return @nav_campaigns if @nav_campaigns.present?

    campaign_ids = Setting::get('menu.main_campaign_ids', default: []).reject(&:blank?)
    return [] if campaign_ids.empty?

    @nav_campaigns = active_campaigns_query
      .includes(:parent)
      .where(id: campaign_ids)
      .where('template != ?', 'sem')
      .order_by_set(campaign_ids)
  end

  def nav_shops
    return @nav_shops if @nav_shops.present?

    nav_shop_ids ||= Setting::get('menu.navigation_shop_ids', default: []).reject(&:blank?)
    return [] if nav_shop_ids.empty?

    @nav_shops = shops.where(id: nav_shop_ids).active_and_visible.order(:title)
  end

  def nav_main_shops
    return @nav_main_shop if @nav_main_shop.present?

    main_shop_ids ||= Setting::get('menu.main_shop_ids', default: []).reject(&:blank?)
    return [] if main_shop_ids.empty?

    @nav_main_shop = shops.where(id: main_shop_ids).active_and_visible.order_by_set(main_shop_ids)
  end

  def footer_campaigns
    return @footer_campaigns if @footer_campaigns.present?

    campaign_ids = Setting::get('menu.footer_campaign_ids', default: []).reject(&:blank?)
    return [] if campaign_ids.empty?

    @footer_campaigns = campaigns.includes(:shop, :parent).where('id in (?)', campaign_ids).order_by_set(campaign_ids)
  end

  def footer_shops
    return @footer_shops if @footer_shops.present?

    shop_ids = Setting::get('menu.footer_shop_ids', default: []).reject(&:blank?)
    return [] if shop_ids.empty?

    @footer_shops = shops.where('id in (?)', shop_ids).order_by_set(shop_ids)
  end

  def static_pages
    active_static_pages_query
  end

  # coupons_by_type
  #
  # Returns active customized coupons filtered by type; e.g. top or exclusive
  #
  # @param  type [String] defines which coupon filter to apply
  # @return [Array] Array of Coupons
  def coupons_by_type(type, opts = {})
    active_coupons_query.by_type(type, opts).order_by_priority
  end

  def coupons_by_categories(category_ids)
    active_coupons_query.includes(:shop, :coupon_categories, :categories).where(categories: { id: category_ids }).order_by_priority
  end

  def coupons_by_shops(shop_ids, order_by_relevance = true)
    if order_by_relevance
      active_coupons_query.where(shop_id: shop_ids).order_by_relevance()
    else
      active_coupons_query.where(shop_id: shop_ids)
    end
  end

  def expiring_coupons
    active_coupons_query.order('DATE(coupons.end_date) ASC').limit(20)
  end

  # categories
  #
  # Returns categories available for current site
  #
  # @return [Array] Categories
  def categories
    active_categories_query
  end

  def main_categories
    active_categories_query.includes(:parent).where(main_category: true)
  end

  def campaigns
    active_campaigns_query
  end

  def shop_sub_pages(shop)
    campaigns
      .where(shop_id: shop.id)
      .includes(:shop)
  end

  def campaign_sub_pages(campaign)
    if campaign.shop_id.present?
      campaigns.where(shop_id: campaign.shop_id).where('campaigns.id != ?', campaign.id)
    elsif campaign.parent_id.present?
      campaigns.where(parent_id: campaign.parent_id).where('campaigns.id != ?', campaign.id)
    else
      campaigns.where(parent_id: campaign.id)
    end
  end


  # find campaigns with either:
  # a shop selected and params[:shop_slug] is set
  # or dont have a shop selected and params[:shop_slug] is nil
  def campaign_by_slug_and_shop_slug(opts = {})
    @site.campaigns.includes(:parent, :shop).find_by(slug: opts[:slug], shops: { slug: opts[:shop_slug] } )
  end

  # settings
  #
  # Returns settings of the current site and by campaign if campaign_id is set OR if Campaign.current is set
  #
  # @param  campaign_id = nil [Integer] Campaign ID
  # @return [OpenStruct] containing the setting value as OpenStruct
  def settings(campaign_id = nil)

    campaign_id ||= Campaign.current ? Campaign.current.id : nil
    setting = Setting.where(name: 'setting', site_id: @site).where("campaign_id is null").first

    if campaign_id.present?
      campaign_settings   = Setting.where(name: 'setting', site_id: @site, campaign_id: campaign_id).first
      campaign_value      = campaign_settings.present? ? campaign_settings.value : OpenStruct.new
      campaign_value_hash = campaign_value.marshal_dump_recursive
      default_value_hash  = setting.present? ? setting.value.marshal_dump_recursive : Hash.new
      setting_values      = default_value_hash.deep_merge(campaign_value_hash)
      @campaign_settings  = setting_values.to_ostruct_recursive
      return @campaign_settings
    end

    @settings = setting.present? ? setting.value : OpenStruct.new
  end

  def style_settings_enabled?
    @style_exists ||= @site.style_settings_enabled?
  end

  # fetch widget_areas for the current site and by campaign_id
  # @param  campaign_id = nil [Integer] Campaign_id of current campaign
  #
  # @return [Array] Array of WidgetAreas
  def widget_areas(campaign_id = nil)
    campaign_id ||= Campaign.current ? Campaign.current.id : nil

    @widget_areas = site.widget_areas.by_campaign(campaign_id)
  end

  # fetch widget for the current site and by campaign_id
  # @param  campaign_id = nil [Integer] Campaign_id of current campaign
  #
  # @return [Array] Array of WidgetAreas
  def widget(name, campaign_id = nil)
    campaign_id ||= Campaign.current ? Campaign.current.id : nil

    @widget = site.widgets.by_campaign(campaign_id).find_by(name: name)
  end

  # popup_widget from main area
  def popup_widget
    campaign_id = Campaign.current ? Campaign.current.id : nil
    area = WidgetArea.find_by(site_id: site.id, name: 'main', campaign_id: campaign_id)
    return area.widgets.select{|w| w.name == 'popup'}.first if area.present?
  end

  # get widgets by widget area and campaign_id if set
  # @param  area [String, Symbol] name of the widget area
  # @param  campaign_id = nil [Integer] Campaign id
  #
  # @return [Array] Array of Widgets
  def widgets_for_area(name, campaign_id = nil)
    campaign_id ||= Campaign.current ? Campaign.current.id : nil
    area = WidgetArea.find_by(site_id: site.id, name: name, campaign_id: campaign_id)

    @widgets = area.present? ? area.widgets : []

    # ticket #CA-801 (footer should use the default footer widget from the frontpage if none is set in the campaign)
    if !campaign_id.nil? &&  @widgets.blank? && (name.to_s == 'footer' || name.to_s == 'sidebar')
      area = WidgetArea.find_by(site_id: site.id, name: name, campaign_id: nil)
      @widgets = area.present? ? area.widgets : []
    end

    @widgets
  end

  def similar_editors_picks(similar_shop_ids, limit = 5)
    coupons_by_shops(similar_shop_ids).where(is_editors_pick: true).limit(limit)
  end

  private

  def active_campaigns_query
    @site.campaigns.active
  end

  def active_categories_query
    @site.categories.active
  end

  def active_coupons_query
    @site.coupons.active.joins(:shop).includes(:shop).visible
  end

  def inactive_coupons_query
    @site.coupons.inactive.joins(:shop)
  end

  def active_shops_query
    @site.shops.active
  end

  def active_static_pages_query
    @site.static_pages.active
  end
end
