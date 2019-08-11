module TrackingHelper

  def content_group_tags
    cg = case params[:controller]
    when 'shops'
      { 1 => 'Shop' }
    when 'categories'
      { 2 => 'Category' }
    when 'campaigns'
      { 3 => 'Campaign' }
    else
      { 4 => 'Other' }
    end

    " data-cg-index='#{cg.keys.first}' data-cg='#{cg.values.first}'".html_safe
  end

  def get_on_click_expired_coupon_event_string(coupon_id)
    push = <<-eos
    _push('event', {
      ec: "Internal Ads",
      ea: 'click',
      el: "expired_coupon",
      ev: "#{coupon_id}",
      promoa: 'promo_click',
      promo1id: "#{coupon_id}",
      promo1nm: 'Expired Coupon',
      promo1ps: "#{params[:controller]}",
      promo1cd1: pc_tracking_user_id
    }, this);
    eos
    push
  end

  def track_click_out(coupon)
    Tracking::Click::Out.new(@site.site, coupon, request, params, cookies).call
  end
end
