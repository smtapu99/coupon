class Widgets::PremiumWidgetService < Widgets::BaseService

  private

  def load_widget_data
    limit = 8
    @coupons = []

    @coupons = @site.coupons.where(id: @widget.coupon_ids.split(','))
    @coupons = @coupons.take(limit)

  end
end
