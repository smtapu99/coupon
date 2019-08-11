class ModalsController < FrontendController
  def help
    I18n.shop_scope = params[:shop_scope]
    @widget = @site.widget('help') || Widget.new(name: 'help')
    @values = widget_values @widget

    render layout: false
  end

  def coupon_clickout
    @coupon = @site.coupon(params[:id])
    @tracking_user = Tracking::User::Fetch.new(@site, request, params, cookies).call
    I18n.shop_scope = @coupon&.shop&.id
    render layout: false
  end

  def coupon_share
    @coupon = Coupon.find_by(id: params[:id])
    render layout: false
  end

  def newsletter_subscribe
    render layout: false
  end

  private

  def widget_values widget
    widget.defaults.merge(widget.value.marshal_dump.select {|k, v| v.present?})
  end
end
