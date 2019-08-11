class FrontendController < ApplicationController

  rescue_from ActionController::RoutingError, with: :render_404

  layout 'frontend'

  helper :all
  include ActionView::Helpers::SanitizeHelper

  include Breadcrumbs
  include OptionHelper
  include CouponHelper
  include ShopHelper
  include ExternalUrlHelper
  include ApplicationHelper
  include TrackingHelper

  before_action :init_site
  before_action :init_campaign
  before_action :init_setting
  before_action :init_translations
  before_action :set_home_breadcrumb
  before_action :set_current_time_zone
  before_action :set_i18n_globals
  before_action :set_layout
  before_action :set_session_vars
  before_action :set_social_image
  before_action :set_shops_for_search_autocomplete
  before_action :set_menu_categories
  before_action :set_global_surrogate_key
  before_action :set_theme
  before_action :set_bucket_asset_path
  before_action :theme_view_path
  theme :theme_resolver

  private

  def add_body_tracking_data
    @tracking_data = ''
    controller = params[:controller]
    action = params[:action]

    case controller
    when 'home'
      @tracking_data = 'Home - Index' if action == 'index'
    when 'shops'
      @tracking_data = 'Shop - ' + @shop.title if action == 'show'
      @tracking_data = 'Shop - Index' if action == 'index'
    when 'categories'
      @tracking_data = 'Category - ' + @category.name if action == 'show'
      @tracking_data = 'Category - Index' if action == 'index'
    when 'coupons'
      if action == 'index'
        case params[:type]
        when 'popular'
          @tracking_data = 'Coupon - Popular'
        when 'new'
          @tracking_data = 'Coupon - New'
        when 'exclusive'
          @tracking_data = 'Coupon - Exclusive'
        when 'free_delivery'
          @tracking_data = 'Coupon - Free Delivery'
        when 'free'
          @tracking_data = 'Coupon - Free'
        when 'expiring'
          @tracking_data = 'Coupon - Expiring'
        else
          @tracking_data = 'Coupon - Top'
        end
      elsif action == 'saved'
        @tracking_data = 'Coupon - Bookmarks'
      end
    when 'campaigns'
      @tracking_data = 'Campaign - ' + @campaign.name if action == 'show'
    when 'searches'
      @tracking_data = 'Search - Index' if action == 'index'
    end
  end

  def set_shops_for_search_autocomplete
    @search_top_shops = @site.shops.with_active_coupons.by_tier_group(1).order_by_priority.limit(10)
    if size = @search_top_shops.size and size < 10
      @search_top_shops += @site.shops.with_active_coupons.order_by_priority.limit(10 - size).where('id not in (?)', @search_top_shops.map(&:id))
    end

    @search_top_shops = @search_top_shops.sort_by(&:title)
  end

  def set_menu_categories
    @menu_categories = @site.main_categories.order(name: :asc)
  end

  def init_html_document_vars(doc, coupons = nil)
    # init variables to avoid nil related errors
    @h1 = ''
    @h2 = ''
    @meta_title = ''
    @meta_description = ''
    @content = ''
    @meta_robots = ''
    @meta_keywords = ''
    @welcome_text = ''
    @stripped_welcome_text = ''

    return unless doc.present?

    # Dynamic variables
    @h1 = doc.dynamic_h1(coupons)
    @h2 = doc.dynamic_h2(coupons)
    @meta_title = doc.dynamic_meta_title(coupons)
    @meta_description = doc.dynamic_meta_description(coupons)

    # Static variables
    @content = doc.content
    @meta_robots = doc.meta_robots
    @meta_keywords = doc.meta_keywords
    @welcome_text = sanitize(doc.welcome_text, tags: %w(strong em b i))
    @stripped_welcome_text = strip_tags(@welcome_text)
  end

  def set_session_vars
    session[:subIdTracking] = cookies[:subIdTracking]
  end

  def set_social_image
    if image = Setting::get('publisher_site.open_graph_image', default: nil) and image.present?
      content_for :social_image, image
    elsif logo = @site.site.image_setting.logo_url and logo.present?
      content_for :social_image, logo
    end
  end

  def redirect_to_home
    redirect_to root_url, status: 301
  end

  def redirect_to_category(category)
    redirect_to dynamic_url_for('category', 'show', slug: category.slug, parent_slug: category.parent_slug, only_path: false), status: 301
  end

  def render_404
    @coupons = Rails.cache.fetch([Site.current.id, 'render_404', 'top_coupons']) do
      @site.coupons_by_type('top').limit(10).to_a
    end
    @tracking_data = 'Error - 404'

    content_for :title, t(:META_TITLE_NOT_FOUND, default: 'META_TITLE_NOT_FOUND')
    add_default_breadcrumbs

    render 'errors/not_found.html', status: :not_found, layout: default_layout
  end

  def set_home_breadcrumb
    add_breadcrumb @site.home_breadcrumb_name, dynamic_url_for('home', 'index', only_path: false)
  end

  def set_i18n_globals
    I18n.shop_scope = nil # XXX: Reset on each request. check shop_controller.rb and initializers/tms.rb
    I18n.global_scope = :frontend
    I18n.locale = @site.locale
  end

  # Initialize the Site Facade
  #
  # @return [Object] Site
  def init_site
    matching_site = Site.multisite_per_request(request)

    Site.current = if matching_site.present?
      matching_site
    else
      Site.by_host(request.host).first
    end

    ## this is used for devloping via a ngrok or localtunnel tunnel... e.g when you want to access your localhost
    # via another hostname like  http://e47905cc.ngrok.io
    if Rails.env.development? && Site.current.blank?
      Site.current = Site.first
    end

    if Site.current.blank?
      redirect_to 'https://cupon.es', status: 302 and return
    else
      @site = SiteFacade.new(Site.current)
    end
  end

  def set_current_time_zone
    if @site.site.present?
      Time.zone = (@site.site.time_zone.present?) ? @site.site.time_zone : 'Berlin'
    end
  end

  def default_url_options
    if @site.site.present?
      { protocol: @site.site.protocol }
    else
      {}
    end
  end

  def init_campaign
    Campaign.current = nil
    return unless params[:controller] == 'campaigns'

    @campaign = @site.campaign_by_slug_and_shop_slug(slug: params[:slug], shop_slug: params[:shop_slug])
    if @campaign.present?
      Campaign.current = @campaign
    end
  end

  def init_translations
    I18n.translations_timestamp = SiteCustomTranslation.maximum(:updated_at).to_i
  end

  # Loads the Settings
  #
  # @return [OpenStruct] Object of Settings
  def init_setting
    Setting.init_setting(@site.site)
  end

  def set_theme
    Theme.current = Setting::get('style.theme', default: 'flat_2016')
  end

  def set_cache_prefix
    if defined?(SecondLevelCache) == 'constant'
      SecondLevelCache.configure.cache_key_prefix = Rails.env.test? ? 'test-' + @site.site.id.to_s : @site.site.id
    end
  end

  def no_index
    content_for :robots, 'noindex, nofollow'
  end

  def set_bucket_asset_path
    @bucket_asset_path = @site.bucket_asset_path
  end

  def theme_view_path
    return if Theme.current == 'flat_2016'
    prepend_view_path 'app/themes/flat_2016/views/'
  end

  def set_layout
    @custom_layout = Option.custom_layout
    @layout = @custom_layout.present? ? 'custom' : 'frontend'

    self.class.layout @layout
  end

  def theme_resolver
    Theme.current.present? ? Theme.current : 'flat_2016'
  end

  def force_xhr
    head(:forbidden) unless request.xhr?
  end

  def default_layout
    Theme.current == 'simple_2019' ? 'sidebar_left' : 'sidebar_right'
  end

  def paginate_categories?
    @paginate_categories ||= Setting.get('publisher_site.paginate_categories', default: 1).to_i == 1
  end
end
