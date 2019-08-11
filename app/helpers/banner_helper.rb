module BannerHelper

  def sticky_banner
    if is_shops_show?
      @site.sticky_banner(shop_id: @shop.try(:id), catgory_id: @top_categories.try(:first).try(:id))
    elsif is_category_show?
      @site.sticky_banner(category_id: @category.try(:id))
    elsif is_home_page?
      @site.sticky_banner(show_on_home_page: true)
    else
      @site.sticky_banner
    end
  end

  def banner_event_action(banner)
    parts = []
    parts << case
    when controller.controller_name == 'home'
      'Home'
    when controller.controller_name == 'shops' && controller.action_name == 'index'
      "Shop - Index"
    when controller.controller_name == 'categories' && controller.action_name == 'index'
      "Category - Index"
    when controller.controller_name == 'coupons' && controller.action_name == 'index'
      "Coupon - #{params[:type]}"
    when controller.controller_name == 'shops' && controller.action_name == 'show' && @shop.present?
      "Shop - #{@shop.title}"
    when controller.controller_name == 'categories' && controller.action_name == 'show' && @category.present?
      "Category - #{@category.name}"
    when controller.controller_name == 'campaigns' && @campaign.present?
      "Campaign - #{@campaign.name}"
    else
      "Error - Not Found"
    end

    parts << 'BA'

    parts << case
    when banner.banner_type == 'sticky_banner'
      'ST'
    when banner.banner_type == 'sidebar_banner'
      'SBB'
    when banner.banner_type == 'shop_banner'
      'SB'
    end

    parts << 'null/null'
    parts << banner.id
    parts.join('/')
  end

  def shop_banner
    banner = @site.shop_banner(shop_id: @shop.try(:id), category_id: @top_categories.try(:first).try(:id))
    return banner if banner.present? and banner.image_url.present? && banner.target_url.present?
  end

  def sidebar_banner
    banner = if is_shops_show?
      @site.sidebar_banner(shop_id: @shop.try(:id), category_id: @top_categories.try(:first).try(:id), is_shops_show: true)
    elsif is_category_show?
      @site.sidebar_banner(category_id: @category.try(:id))
    else
      @site.sidebar_banner
    end

    return banner if banner.present? and banner.content.present? || (banner.image_url.present? && banner.target_url.present?)
  end

  def is_shops_show?
    controller_name == 'shops' && action_name == 'show'
  end

  def is_coupons_index?
    controller_name == 'coupons' && action_name == 'index'
  end

  def is_category_show?
    controller_name == 'categories' && action_name == 'show'
  end

  def is_campaign_sem?
    controller_name == 'campaigns' && action_name == 'sem'
  end

  def is_home_page?
    controller_name == 'home' && action_name == 'index'
  end

  def show_flyout_notification?
    is_shops_show? && \
      @shop.present? && \
      @coupons.present? && \
      Setting.get('experimental.shops_with_flyout_coupon', default: []).include?(@shop.id.to_s)
  end

  def show_sticky_banner?(banner)
    begin
      URI.parse(banner.target_url).path != request.path && !is_campaign_sem?
    rescue Exception => e
      return false
    end
  end

end
