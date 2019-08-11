module Admin
  class SettingsController < BaseController
    before_action :authenticate_admin_user!
    load_and_authorize_resource

    before_action :set_setting, only: [:index, :update]
    before_action :inform_settings_changed, only: [:update]
    before_action :set_last_setting_session, only: [:update]
    before_action :restore_defaults, only: [:update]

    after_action :purge_proxy_cache, only: [:update]

    def index
      set_dropdowns
      flash[:error] = 'Cache Settings Missing' unless @setting.caching.present?
      flash[:error] = 'Home Breadcrumb Name is missing in Site Settings' if @setting.home_breadcrumb_name_needed?
    end

    def update
      respond_to do |format|
        if @setting.update(setting_params)

          notice = if Setting.routes_changed
            'Route Settings were successfully saved. Home page cache was not cleared to avoid server overload.'
          else
            'Settings were successfully updated.'
          end

          format.html { redirect_to admin_settings_url, notice: notice }
        else
          set_dropdowns
          format.html { render action: 'index' }
        end
      end
    end

    def update_image_settings
      @image_setting = ImageSetting.find_or_create_by(site_id: Site.current.id)

      respond_to do |format|
        if @image_setting.update(image_setting_params)
          Setting.image_upload_changed = true
          format.html { redirect_to admin_settings_url, notice:  'Image Settings were successfully updated.' }
        else
          set_dropdowns
          format.html { render action: 'index' }
        end
      end
    end

    def reload_routes
      validate_super_admin
      head(:not_found) and return unless Site.current.present?

      RoutesChangedTimestamp.update_timestamp(Site.current)
      redirect_to admin_root_path, notice: "Routes for Site #{Site.current.hostname} are getting reloaded!"
    end

    private

    def purge_proxy_cache
      unless Setting.routes_changed
        CacheService.new(Site.current).purge(url_for(send("root_#{Site.current.id}_url")))
      end
    end

    def set_setting
      @setting = Setting.find_or_create_by(site_id: Site.current.id, campaign_id: nil)
      @image_setting = ImageSetting.find_or_create_by(site_id: Site.current.id)
    end

    def image_setting_params
      params.require(:image_setting).permit(
        :favicon,
        :remove_favicon,
        :logo,
        :remove_logo,
        :hero,
        :remove_hero,
        :see_more_categories_background,
        :remove_see_more_categories_background
      )
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def setting_params
      params.permit(
        style: [
          :styles_enabled,
          :theme,
          :fallback_theme,
          :color_text,
          :color_headline,
          :color_cloud,
          :color_ready,
          :color_sky,
          :color_royal,
          :color_freedom,
          :color_brand_primary,
          :color_brand_secondary,
          :color_brand_tertiary,
          :color_brand_quaternary,
          :header_bg_color,
          :header_font_color_primary,
          :main_bg_color,
          :main_box_border_color,
          :main_font_color_primary,
          :main_font_color_secondary,
          :main_font_color_tertiary,
          :main_text_link_color,
          :footer_bg_footer,
          :footer_font_color_primary,
          :footer_font_color_secondary,
          :font_family_base,
          :font_family_h1,
          :font_family_h2,
          :font_family_h3,
          :font_family_h4
        ],
        publisher_site: [
          :show_home_link,
          :home_breadcrumb_name,
          :blog_link_title,
          :blog_link_url,
          :external_logo_url,
          :external_logo_rel_attr,
          :allow_coupon_bookmarks,
          :show_news_popup_for_empty_shop,
          :show_disclaimer,
          :disclaimer_text,
          :show_footer,
          :wls_footer_style,
          :show_social_media_column,
          :currency_symbol_position,
          :days_coupon_is_new,
          :shop_pages_title_structure,
          :inline_newsletter_position,
          :hide_coupons_of_sub_pages,
          :show_prominent_search_on_homepage,
          :twitter_site,
          :facebook_site,
          :facebook_app_id,
          :facebook_admin_ids,
          :show_fb_comments,
          :show_topbar,
          :show_crosslinks,
          :open_graph_image,
          :hide_star_rating,
          :hide_expired_coupons,
          :paginate_categories,
          :unpaginate_coupons_count,
          :summary_widget,
          :secondary_summary_widget,
          :reduced_js_features,
          :hero_links,
          :anchors_for_summary_widget,
          navigation_shop_ids: [],
          summary_shop_ids: [],
          premium_summary_shop_ids: [],
          footer_shop_ids: [],
          footer_campaign_ids: [],
          featured_shop_ids: []
        ],
        routes: [
          :application_root_dir,
          :page_show,
          :category,
          :category_show,
          :subcategory_show,
          :go_to_coupon,
          :popular_coupons,
          :top_coupons,
          :new_coupons,
          :expiring_coupons,
          :free_delivery_coupons,
          :free_coupons,
          :exclusive_coupons,
          :campaign_page,
          :campaign_sub_page,
          :shop_campaign_page,
          :search_page,
          :shop_index,
          :shop_show,
          :contact_form,
          :partner_form,
          :report_form
        ],
        legal_pages: [
          :about_us_url,
          :imprint_url,
          :terms_and_conditions_url,
          :privacy_policy_url,
          :press_url,
          :cookie_policy_url,
          :faq_url
        ],
        newsletter: [
          :newsletter_enabled,
          :mailchimp_api_key,
          :mailchimp_list_id
        ],
        homepage: [
          :title,
          :meta_title,
          :meta_description,
          :meta_robots,
          :head_scripts,
          search_box_shops: [],
          search_box_shops_popular: []
        ],
        admin_rules: [
          :canonical_domain,
          :dynamic_pages,
          :static_pages,
          :robots_txt,
          :cookie_policy_url
        ],
        mail_forms: [
          :contact_emails,
          :contact_form_enabled,
          :partner_form_enabled,
          :report_form_enabled
        ],
        caching: [
          :proxy_server_type,
          :fastly_auth_key,
          :fastly_service_id,
          :fastly_cache_purge_host,
          :use_surrogate_keys,
          :cloudflare_zone_id
        ],
        visibility: [
          :coupon_properties,
          :coupon_description,
          :site_header,
          :shop_header
        ],
        tracking: [
          :google_analytics_id,
          :google_tag_manager_id,
          :client_google_tag_manager_id,
          :head_scripts,
          :body_scripts
        ],
        banner: [
          :theme,
          :caption_heading,
          :caption_body,
          :default_banner_img_url,
          :default_banner_logo_url,
          :default_banner_font_color,
          :default_banner_cta_background,
          :default_banner_cta_color,
          :button_text,
          :start_date,
          :end_date,
          :countdown_date,
          :show_banner,
          :target_url
        ],
        shop_banner: [
          :show_banner,
          :image_url,
          :target_url,
          :show_banner,
          :target_url,
          excluded_shop_ids: []
        ],
        alert: [
          :uniq_coupons_threshold
        ],
        menu: [
          :show_home_link,
          :show_categories,
          :show_coupons,
          :show_campaigns,
          navigation_shop_ids: [],
          navigation_category_ids: [],
          main_shop_ids: [],
          main_campaign_ids: [],
          footer_shop_ids: [],
          footer_campaign_ids: []
        ],
        experimental: [
          :flyout_style,
          shops_with_elevated_coupons: [],
          shops_with_flyout_coupon: []
        ]
      )
    end

    def set_dropdowns
      shops = Site.current.shops.active
      campaigns = Site.current.campaigns.active
      categories = Site.current.categories.active

      @featured_shop_ids_collection = shops.order_by_set(@setting.publisher_site.try(:featured_shop_ids)).collect { |i| [i.title_and_site_name, i.id] }
      @navigation_shop_ids_collection = shops.order_by_set(@setting.menu.try(:navigation_shop_ids)).collect { |i| [i.title_and_site_name, i.id] }
      @navigation_category_ids_collection = categories.order_by_set(@setting.menu.try(:navigation_category_ids)).collect { |i| [i.name, i.id] }
      @main_shop_ids_collection = shops.order_by_set(@setting.menu.try(:main_shop_ids)).collect { |i| [i.title_and_site_name, i.id] }
      @main_campaign_ids_collection = campaigns.active.order_by_set(@setting.menu.try(:main_campaign_ids)).collect { |i| [i.id_and_nav_title_or_name, i.id] }
      @search_box_shops_collection = shops.order_by_set(@setting.menu.try(:search_box_shops)).collect { |i| [i.title_and_site_name, i.id] }
      @search_box_shops_popular_collection = shops.order_by_set(@setting.menu.try(:search_box_shops_popular)).collect { |i| [i.title_and_site_name, i.id] }
      @footer_shop_ids_collection = shops.order_by_set(@setting.menu.try(:footer_shop_ids)).collect { |i| [i.title_and_site_name, i.id] }
      @footer_campaign_ids_collection = campaigns.order_by_set(@setting.menu.try(:footer_campaign_ids)).collect { |i| [i.id_and_nav_title_or_name, i.id] }
      @excluded_shop_ids_collection = Site.current.shops.order_by_set(@setting.shop_banner.try(:excluded_shop_ids)).collect { |i| [i.title_and_site_name, i.id] }
      @summary_shop_ids_collection = Site.current.shops.active.order_by_set(@setting.publisher_site.try(:summary_shop_ids)).collect { |i| [i.title_and_site_name, i.id] }
      @premium_summary_shop_ids_collection = Site.current.shops.active.order_by_set(@setting.publisher_site.try(:premium_summary_shop_ids)).collect { |i| [i.title_and_site_name, i.id] }
      @shops_with_elevated_coupons_collection = Site.current.shops.active.order_by_set(@setting.publisher_site.try(:shops_with_elevated_coupons_collection)).collect { |i| [i.title_and_site_name, i.id] }
      @shops_with_flyout_coupon_collection = Site.current.shops.active.order_by_set(@setting.publisher_site.try(:shops_with_flyout_coupon_collection)).collect { |i| [i.title_and_site_name, i.id] }
      @flyout_style_options = Option.get_select_options('flyout_style', false)
    end

    def inform_settings_changed
      Setting.reset_changed_flags
      Setting.send("#{setting_params.to_h.keys.first}_changed=", true)
    end

    def set_last_setting_session
      session[:last_setting] = setting_params.keys.first
    end

    def restore_defaults
      return unless params[:commit] == 'Restore Defaults'

      @setting.style = {}
      @setting.save
      redirect_to admin_settings_path
    end
  end
end
