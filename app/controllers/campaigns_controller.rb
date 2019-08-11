class CampaignsController < FrontendController
  before_action :check_redirection, only: [:show, :sem]
  before_action :load_coupons, only: [:show, :sem]
  before_action :set_metas, only: [:show, :sem]

  def show
    @sub_pages = @site.campaign_sub_pages(@campaign)

    @settings = @site.settings # reinitialize the settings here so that we load them together with campaign settings !! necessary !!
    @shop_filter_size = @coupons_no_pagination.reorder(nil).group(:shop_id).size
    @order_by_id_string = @shop_filter_size.sort_by { |_key, value| value }.reverse.map { |s| s[0] }.join(',')
    @shops = @site.shops.where(id: @coupons_no_pagination.map(&:shop_id)).order(Arel.sql("FIND_IN_SET(id, '" + @order_by_id_string + "') ASC"))

    content_for :head, Setting::get('publisher_site.custom_head_scripts').html_safe if Setting::get('publisher_site.custom_head_scripts').present?

    add_default_breadcrumbs
    add_body_tracking_data

    case true
    when Theme.current == 'simple_2019'
      render 'campaigns/templates/grid', layout: 'no_sidebar'
    when @campaign.is_themed? && @custom_layout.blank?
      # any site that is not customized and able to show the full themed header
      render 'campaigns/templates/themed', layout: 'empty'
    when @campaign.is_themed? && @custom_layout.present?
      # Fallback for custom layout fullwidth sites where themed.html looks good
      if [17, 33, 24, 43, 18, 50, 45, 44, 30].include?(Site.current.id)
        render 'campaigns/templates/themed', layout: 'custom'
      else
        # otherwise show grid template with themed widgets
        render 'campaigns/templates/grid', layout: params[:filter].present? ? false : 'no_sidebar'
      end
    when @campaign.is_grid?
      render "campaigns/templates/#{@campaign.template}", layout: params[:filter].present? ? false : 'no_sidebar'
    else
      render layout: params[:filter].present? ? false : default_layout
    end
  end

  def sem
    render layout: 'empty'
  end

  private

  def load_coupons
    @coupons_no_pagination = @site.campaign_coupons(@campaign)

    if @campaign.shop_id.present?
      @coupons = @coupons_no_pagination.page(params[:page]).per(@coupons_no_pagination.size) # disable pagination in subpages of shops
    else
      @coupons = @coupons_no_pagination.page(params[:page])
    end

    if params[:shop_id].present? && params[:category_id].present?
      @coupons = @coupons.includes(:coupon_categories).where('coupon_categories.category_id IN (?) OR shops.id IN (?)', params[:category_id], params[:shop_id])
    elsif params[:shop_id].present?
      @coupons = @coupons.where(shop_id: params[:shop_id])
    elsif params[:category_id].present?
      @coupons = @coupons.includes(:coupon_categories).where(coupon_categories: {category_id: params[:category_id]})
    end

    surrogate_key_header [
      'coupons', @coupons.map(&:resource_key),
      'campaigns', @campaign.resource_key
    ]
  end

  def set_metas
    dynamic_pages = Setting::get('admin_rules.dynamic_pages')
    content_for :canonical, original_url_with_custom_protocol.split('?').first

    if @campaign.html_document.present?
      doc = @campaign.html_document

      init_html_document_vars(doc, @coupons_no_pagination)

      content_for :description, @meta_description
      content_for :keywords, @dynamic_meta_keywords
      content_for :title, @meta_title
    end

    if @campaign.template == 'sem'
      content_for :robots, 'noindex,nofollow'
    elsif params[:page].present?
      content_for :robots, 'noindex,follow'
    elsif dynamic_pages.present? && dynamic_pages == 'noindex'
      content_for :robots, 'noindex,nofollow'
    elsif @meta_robots.present?
      content_for :robots, @meta_robots
    else
      content_for :robots, 'index,follow'
    end
  end

  def check_redirection
    return not_found unless @campaign.present?
    return not_found if params[:action] == 'show' && @campaign.template == 'sem'
    return not_found if params[:action] == 'sem' && @campaign.template != 'sem'
    redirect_to dynamic_campaign_url_for(@campaign) and return if parent_or_shop_param_missing?
    redirect_to dynamic_campaign_url_for(@campaign) and return if redirect_to_root_campaign?
    return not_found if parent_or_shop_param_redundant?

    if @campaign.is_gone? || @campaign.is_blocked?
      if @campaign.parent_or_shop_present? && !@campaign.has_inactive_parent?
        return redirect_to url_for_parent_or_shop
      end

      if @campaign.is_gone?
        return render_404
      end

      return redirect_to_category(@campaign.category) if @campaign.category

      return redirect_to_home
    end

    if @campaign.has_inactive_parent?
      if category = @campaign.category
        return redirect_to_category(category)
      else
        return render_404
      end
    end
  end

  def redirect_to_root_campaign?
    @campaign.is_root_campaign? && remove_protocol(request.url) != remove_protocol(dynamic_campaign_url_for(@campaign))
  end

  def parent_or_shop_param_missing?
    return true if @campaign.parent.present? && !params[:parent_slug].present?
    return true if @campaign.shop.present? && !params[:shop_slug].present?
    return false
  end

  def remove_protocol(string)
    string.sub(/https?\:(\\\\|\/\/)/,'')
  end

  def parent_or_shop_param_redundant?
    return true if !@campaign.parent.present? && params[:parent_slug].present?
    return true if !@campaign.shop.present? && params[:shop_slug].present?
    return false
  end

  def url_for_parent_or_shop
    if @campaign.parent.present?
      dynamic_url_for('campaign', 'show', slug: @campaign.parent_slug)
    elsif @campaign.shop.present?
      dynamic_url_for('shops', 'show', slug: @campaign.shop_slug)
    end
  end
end
