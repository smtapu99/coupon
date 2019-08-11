class Widgets::RotatedCouponsService < Widgets::BaseService
  private

  def load_widget_data
    limit = 15

    coupon_ids = @widget.rotated_coupon_ids.delete(' ').split(',').uniq.sample(limit)
    @coupons = @site.coupons.where(id: coupon_ids)
    @coupons += @site.coupons.active.where.not(id: @coupons.map(&:id)).limit(limit - @coupons.count) if @coupons.count < limit
  end
end
