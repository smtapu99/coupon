class Widgets::DiscountBubblesService < Widgets::BaseService

  private

  def load_widget_data
    @error = false
    @discount_bubbles = []

    @widget.value[:discount_bubbles].each do |offer|
      next unless offer[:coupon_id].present?

      begin
        coupon = @site.coupons.find(offer[:coupon_id])
        offer[:coupon] = coupon
        @discount_bubbles << offer
      rescue ActiveRecord::RecordNotFound
        @error = true
        return
      end
    end
  end
end
