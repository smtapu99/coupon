module ShopHelper

  def is_popular_shop_test?
    # TODO: remove when test has been concluded
    return true if Rails.env.development? && Site.current.id == 1
    [42,49,59,69,80,84].include?(Site.current.id)
  end

  def show_summary_widget_in_content?(shop)
    return false if !is_shop_show? || !shop.present?

    allowed_shop_ids = Setting::get('publisher_site.summary_shop_ids', default: []).map(&:to_i)
    allowed_shop_ids.include?(shop.id)
  end

  def show_premium_summary_widget_in_content?(shop)
    return false if !is_shop_show? || !shop.present?

    allowed_shop_ids = Setting::get('publisher_site.premium_summary_shop_ids', default: []).map(&:to_i)
    allowed_shop_ids.include?(shop.id)
  end

  def shop_id_in_params id
    return false unless params['shop_id'].present?

    params['shop_id'].include?(id.to_s)
  end

  def related_shops_blocked? shop
    Setting::get('publisher_site.shops_without_related_shops_widget', default: []).map(&:to_s).include? shop.id.to_s
  end

  def is_shop_show?
    params[:controller] == 'shops' && params[:action] == 'show'
  end

  def join_info_option_array method, data
    options = Option::get_select_options(method, true) rescue {}
    res     = data.map do |d|
      val  = options.select{|k, v| v == d}.keys.first.to_s
      out  = "<span class='label'>"
      out += t(val, default: val) if val.present?
      out += '</span>'
    end
    return res.join(' ').html_safe if(res.size >= 1)
  end

  def sanitize_url url
    unless url[/\Ahttp:\/\//] || url[/\Ahttps:\/\//]
      return "http://#{url}"
    end
    url
  end

  def shop_editors_pick_coupon(coupons)
    coupons.where(is_editors_pick: true).first
  end

  def shop_exclusive_coupon(coupons)
    coupons.where(is_exclusive: true).first
  end

  def shop_flyout_coupon(coupons)
    exclusive = shop_exclusive_coupon(coupons)
    return exclusive if exclusive.present?
    coupons.first
  end

  def flyout_event_action
    "Shop - #{@shop.title}/BA/FLY/null/null/#{@shop.id}"
  end
end
