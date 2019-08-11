class CategoriesController < FrontendController
  before_action :load_category, only:[:show]
  before_action :check_redirection, only: [:show]
  before_action :set_metas, only: [:index]

  def index
    @categories = @site.main_categories.order(name: :asc)
    surrogate_key_header 'categories', @categories.map(&:resource_key)
    add_default_breadcrumbs
    add_body_tracking_data

    render layout: 'no_sidebar'
  end

  def show
    @categories = @site.main_categories.order(name: :asc)
    @coupons_no_pagination = @site.coupons_by_categories(@category.id)
    @category_shops = @category.shops_by_shop_category.active.visible.order(title: :asc).group(:title)

    if paginate_categories?
      @coupons = @coupons_no_pagination.page params[:page]
    else
      @coupons = @coupons_no_pagination.limit(Setting::get('publisher_site.unpaginate_coupons_count', default: 25))
    end

    @coupons = @coupons.where(shop_id: params[:shop_id]) if params[:shop_id].present?

    @shops = @site.shops.visible.order(title: :asc).where(id: @coupons_no_pagination.map(&:shop_id).uniq)

    @site.relevant_categories = [@category]

    surrogate_key_header 'coupons', @coupons.map(&:resource_key), 'categories', @category.resource_key

    # metas
    dynamic_pages = Setting::get('admin_rules.dynamic_pages')
    content_for :canonical, original_url_with_custom_protocol.split('?').first

    if @category.html_document.present?
      doc = @category.html_document

      init_html_document_vars(doc, @coupons_no_pagination)

      content_for :description, @meta_description
      content_for :keywords, @dynamic_meta_keywords
      content_for :title, @meta_title
    end

    if params[:page].present?
      content_for :robots, 'noindex,follow'
    elsif dynamic_pages == 'noindex'
      content_for :robots, 'noindex,nofollow'
    elsif @meta_robots.present?
      content_for :robots, @meta_robots
    else
      content_for :robots, 'index,follow'
    end

    # END metas
    add_default_breadcrumbs
    add_body_tracking_data
    render layout: default_layout
  end

  private

  def load_category
    @category = @site.site.categories.find_by(slug: params[:slug])
  end

  def set_metas
    content_for :title, t(:META_TITLE_CATEGORY_OVERVIEW, default: 'META_TITLE_CATEGORY_OVERVIEW').html_safe

    dynamic_pages = Setting::get('admin_rules.dynamic_pages')

    if dynamic_pages.present?
      case dynamic_pages
      when 'noindex'
        content_for :robots, 'noindex,nofollow'
      else
        content_for :robots, 'index,follow'
      end
    end
  end

  def check_redirection
    return not_found unless @category

    unless @category.is_active?
      if @category.parent.present?
        redirect_to dynamic_url_for('category', 'show', slug: @category.parent.slug) and return
      else
        render_404 and return if @category.is_gone?

        redirect_to_home
      end
    end
  end
end
