class SitemapsController < FrontendController
  before_action :check_sitemap_type

  def index
    @hostname = @site.site.hostname

    set_cache_buster

    respond_to do |format|
      format.xml  { render "sitemaps/splits/#{@type}", layout: false }
      format.all  { redirect_to '/sitemap.xml', status: :moved_permanently }
    end
  end

  private

  def check_sitemap_type
    @type = params[:type] || 'index'
    @index_dynamic_pages = Setting::get('admin_rules.dynamic_pages') != 'noindex' || Setting::get('admin_rules.dynamic_pages').nil?
    @index_static_pages = Setting::get('admin_rules.static_pages') != 'noindex' || Setting::get('admin_rules.static_pages').nil?

    not_found and return unless allow_sitemap?
  end

  # check whether the sitemap should show or not
  def allow_sitemap?
    return true if is_dynamic_page_type? && @index_dynamic_pages
    !site_is_noindex?
  end

  def site_is_noindex?
    !@index_dynamic_pages && !@index_static_pages
  end

  def is_dynamic_page_type?
    ['shops', 'campaigns'].include?(@type.to_s) && @index_dynamic_pages
  end
end
