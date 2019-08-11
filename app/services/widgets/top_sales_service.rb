class Widgets::TopSalesService < Widgets::BaseService

  private

  def load_widget_data
    @error = false
    @top_sales = []

    @widget.value[:top_sales].each do |offer|
      next unless offer[:coupon_id].present?

      begin
        coupon = @site.coupons.find(offer[:coupon_id])
        offer[:coupon] = coupon
        @top_sales << offer
      rescue ActiveRecord::RecordNotFound
        @error = true
        return
      end
    end

    unless @top_sales.size == 4
      @error = true
    end
  end
end
