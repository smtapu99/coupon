class CouponsController < FrontendController
  before_action :set_metas, only: [:index]

  def index
    coupons_no_pagination = @site.coupons_by_type(params[:type])

    # show only 1 coupons per shop on the first page if type == 'new'
    first_page_coupons = params[:type] == 'new' ? @site.coupons_by_type(params[:type]).group(:shop_id) : []
    if first_page_coupons.present? && params[:page].nil?
      coupons_no_pagination = first_page_coupons
    else
      coupons_no_pagination = @site.coupons_by_type(params[:type], exclude: first_page_coupons)
    end

    if paginate_categories?
      @coupons = coupons_no_pagination.page(params[:page]).per(20)
    else
      @coupons = coupons_no_pagination.limit(25)
    end

    @site.visible_coupons = @coupons

    @top_coupons = []

    unless @coupons.present?
      @top_coupons = @site.coupons.by_type('top').order(clicks: :desc).limit(10)
    end

    surrogate_key_header 'coupons', 'coupons_index', @coupons.map(&:resource_key)

    add_default_breadcrumbs
    add_body_tracking_data
    render layout: default_layout
  end

  def clickout
    @coupon = Coupon.status_active.find_by(id: params[:id], site_id: Site.current.id) || not_found
    return redirect_to_shop if @coupon.has_expired?

    process_clickout

    return redirect_to_url if @coupon.shop.is_direct_clickout
    render :clickout_redirect, layout: 'empty'
  end

  def api_clickout
    @coupon = @site.coupon(params[:id])
    return head(:not_found) unless @coupon.present?

    process_clickout
    render layout: 'empty'
  end

  def voucher
    @coupon = @site.coupons.find(params[:id]) || not_found
    respond_to do |format|
      format.html { redirect_to dynamic_url_for('shops', 'show', slug: @coupon.shop.slug) }
      format.js
    end
  end

  def vote
    params.require(:id)
    params.require(:type)

    @coupon = Coupon.find(params[:id]) || not_found
    respond_to do |format|
      if @coupon.add_vote(params[:type])
        format.js
      end
    end
  end

  private

  def process_clickout
    @coupon.add_click
    @redirect_url = @coupon.url_with_tracking_click(track_click_out(@coupon).uniqid)
    set_clickout_metas(@coupon)
  end

  def redirect_to_shop
    redirect_to(dynamic_url_for('shops', 'show', slug: @coupon.shop_slug, only_path: false, expired: @coupon.id), status: :found)
  end

  def redirect_to_url
    redirect_to(@redirect_url, status: :temporary_redirect)
  end

  def set_clickout_metas(coupon)
    tracking_settings = @site.settings.tracking if @site.settings.present?

    content_for :redirect_url, @redirect_url
    content_for :title, coupon.meta_title
    content_for :robots, 'noindex, nofollow'
    if tracking_settings.present?
      content_for :head, tracking_settings.head_scripts.html_safe if tracking_settings.head_scripts.present?
      content_for :body, tracking_settings.body_scripts.html_safe if tracking_settings.body_scripts.present?
    end
    surrogate_key_header 'coupons', [coupon.resource_key]
  end

  def set_metas
    content_for :title, meta_title_for(params[:type])
    content_for :description, meta_description_for(params[:type])

    dynamic_pages = Setting::get('admin_rules.dynamic_pages', default: 'noindex')

    if params[:page].present?
      content_for :robots, 'noindex, nofollow'
    elsif dynamic_pages == 'index_plus_canonical' && !paginate_categories?
      content_for :robots, 'index, follow'
    else
      content_for :robots, 'noindex, nofollow'
    end
  end

  def meta_title_for(type)
    case type
    when 'popular'
      t('META_TITLE_COUPON_POPULAR', default: 'META_TITLE_COUPON_POPULAR')
    when 'top'
      t('META_TITLE_COUPON_TOP', default: 'META_TITLE_COUPON_TOP')
    when 'new'
      t('META_TITLE_COUPON_NEW', default: 'META_TITLE_COUPON_NEW')
    when 'expiring'
      t('META_TITLE_COUPON_EXPIRING', default: 'META_TITLE_COUPON_EXPIRING')
    when 'free_delivery'
      t('META_TITLE_COUPON_FREE_DELIVERY', default: 'META_TITLE_COUPON_FREE_DELIVERY')
    when 'free'
      t('META_TITLE_COUPON_FREE', default: 'META_TITLE_COUPON_FREE')
    when 'exclusive'
      t('META_TITLE_COUPON_EXCLUSIVE', default: 'META_TITLE_COUPON_EXCLUSIVE')
    else
      t('META_TITLE_COUPON_FALLBACK', default: 'META_TITLE_COUPON_FALLBACK')
    end
  end

  def meta_description_for(type)
    case type
    when 'popular'
      t('META_DESCRIPTION_COUPON_POPULAR', default: 'META_DESCRIPTION_COUPON_POPULAR')
    when 'top'
      t('META_DESCRIPTION_COUPON_TOP', default: 'META_DESCRIPTION_COUPON_TOP')
    when 'new'
      t('META_DESCRIPTION_COUPON_NEW', default: 'META_DESCRIPTION_COUPON_NEW')
    when 'expiring'
      t('META_DESCRIPTION_COUPON_EXPIRING', default: 'META_DESCRIPTION_COUPON_EXPIRING')
    when 'free_delivery'
      t('META_DESCRIPTION_COUPON_FREE_DELIVERY', default: 'META_DESCRIPTION_COUPON_FREE_DELIVERY')
    when 'free'
      t('META_DESCRIPTION_COUPON_FREE', default: 'META_DESCRIPTION_COUPON_FREE')
    when 'exclusive'
      t('META_DESCRIPTION_COUPON_EXCLUSIVE', default: 'META_DESCRIPTION_COUPON_EXCLUSIVE')
    else
      t('META_DESCRIPTION_COUPON_FALLBACK', default: 'META_DESCRIPTION_COUPON_FALLBACK')
    end
  end
end
