class PagesController < FrontendController
  def show
    @page = StaticPage.find_by(slug: params[:slug], status: 'active', site_id: @site.site.id) || not_found

    # metas
    content_for :canonical, original_url_with_custom_protocol.split('?').first
    content_for :title, @page.title.html_safe if @page.title.present?

    static_pages = Setting::get('admin_rules.static_pages')

    if @page.html_document.present?
      init_html_document_vars(@page.html_document)

      if @meta_title.present?
        content_for :meta_title, @meta_title
        add_breadcrumb @meta_title, request.original_url
      end
      content_for :description, @meta_description
      content_for :keywords, @meta_keywords
    end

    if static_pages.present?
      case static_pages
      when 'noindex'
        content_for :robots, 'noindex,nofollow'
      else
        if @meta_robots.present?
          content_for :robots, @meta_robots
        else
          content_for :robots, 'index,follow'
        end
      end
    end
    # END metas
  end

  def header
    content_for :robots, 'noindex,nofollow'
    render layout: false
  end

  def footer
    content_for :robots, 'noindex,nofollow'
    render layout: false
  end
end
