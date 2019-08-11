class SearchesController < FrontendController
  before_action :sanitize_query, only: [:index, :shop_autocomplete]

  def index
    @shops = []
    @top_coupons = []

    if @query.present?
      # check if maybe a shop was searched
      @shops = Shop.algolia_search(@query, hitsPerPage: 1000)

      # then redirect to the shop if a single record was found
      if @shops.size == 1 && !reduced_js_features?
        redirect_to dynamic_url_for('shops', 'show', slug: @shops.first.slug, only_path: false), status: 302 and return
      end

      # otherwise get the coupons
      @coupons = @site.coupons_by_shops(@shops).page(params[:page]) # Coupon.elastic_active(search_params)
    end

    if !request.xhr? && @coupons.blank?
      # get coupons if this shop even when inactive
      @top_coupons += related_coupons_by_shop(@shops.first, 5) if @shops.first.present?
      @top_coupons += @site.coupons.by_type('top').order(clicks: :desc).limit(5) if @top_coupons.count < 5
    end

    # metas
    content_for :robots, 'noindex,follow'
    content_for(:title, t(:META_TITLE_SEARCH_PAGE, default: 'META_TITLE_SEARCH_PAGE {search_query}').gsub('{search_query}', @query))
    # END metas

    # this defines which link to show on the coupons thumbnails
    @show_clickout_link = true

    add_default_breadcrumbs
    add_body_tracking_data

    render layout: request.xhr? ? false : default_layout
  end

  def shop_autocomplete
    force_xhr; return if performed?

    @shops = if @query.present?
      Shop.active_and_visible.algolia_search(@query, hitsPerPage: 10)
    else
      @search_top_shops
    end

    render layout: false
  end

  private

  def sanitize_query
    @query = Rails::Html::FullSanitizer.new.sanitize(search_params[:query]) || ''
    @query = CGI.unescapeHTML(@query)
  end

  def related_coupons_by_shop(shop, limit)
    coupons = Rails.cache.fetch([@site.site.id, 'search-rcbs', shop.id], expires_in: 30.minutes ) do
      coupon_ids   = shop.coupon_ids

      category_ids = CouponCategory.where(coupon_id: coupon_ids).pluck(:category_id) rescue []

      coupons_query = @site.coupons_by_categories(category_ids).where('coupons.id not in (?)', coupon_ids)

      coupons = coupons_query
      coupons = coupons.order(clicks: :desc)
      coupons = coupons.limit(limit)

      coupons
    end

    coupons
  end

  def record_not_found
    @coupons = []
    if params[:_f].nil?
      redirect_to send("searches_index_#{@site.site.id}_path", query: params[:query], _f: 1) and return
    else
      render layout: default_layout, action: 'index' and return
    end
  end

  def search_params
    params.permit(:query, :page, shop_id: [], category_id: [])
  end

  def get_shops_filter_size
    sizes = {}

    @coupons_no_pagination.each do |c|
      sizes[c.shop_id] ||= 0
      sizes[c.shop_id] += 1
    end

    sizes
  end
end
