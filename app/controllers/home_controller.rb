class HomeController < FrontendController
  # GET '/' frontpage
  def index
    limit = (Theme.current == 'flat_2016' || Theme.current == 'flat_2016_webpacked') ? 18 : 11
    @campaign = Campaign.current
    @shops_featured = @site.featured_shops_home(limit)
    @shops_featured += @site.featured_shops_home_fallback(limit - @shops_featured.size, @shops_featured.map(&:id))

    home_page_settings = @site.settings.homepage if @site.settings.present?

    canonical_domain = Setting::get('admin_rules.canonical_domain')
    static_pages = Setting::get('admin_rules.static_pages')

    # metas
    content_for :canonical, canonical_domain if canonical_domain.present?

    if home_page_settings.present?
      content_for :head, home_page_settings.head_scripts.html_safe            if home_page_settings.head_scripts.present?
      content_for :description, home_page_settings.meta_description.html_safe if home_page_settings.meta_description.present?
      content_for :meta_title, home_page_settings.meta_title.html_safe        if home_page_settings.meta_title.present?
      content_for :title, home_page_settings.title.html_safe                  if home_page_settings.title.present?
    end

    if static_pages.present?
      case static_pages
      when 'noindex'
        content_for :robots, 'noindex,nofollow'
      else
        if home_page_settings.present? && home_page_settings.meta_robots.present?
          content_for :robots, home_page_settings.meta_robots
        else
          content_for :robots, 'index,follow'
        end
      end
    end

    # END metas
    add_body_tracking_data
    surrogate_key_header "home_#{@site.site.id}"
  end

  def invalid_route
    not_found
  end
end
