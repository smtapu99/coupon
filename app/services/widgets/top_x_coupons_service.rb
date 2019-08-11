class Widgets::TopXCouponsService < Widgets::BaseService

  private

  def load_widget_data
    amount       = (@widget.amount.present?) ? @widget.amount : 5
    @coupons     = []

    excluded_ids = [0] + @site.visible_coupon_ids

    if @site.relevant_categories.present?
      @coupons = @coupons + @site.coupons_by_type('top').by_categories(@site.relevant_categories).group(:shop_id).limit(amount.to_i).where("coupons.id not in (?)", excluded_ids)
      excluded_ids = excluded_ids + @coupons.map(&:id)
    end

    @coupons = @coupons + @site.coupons_by_type('top').group(:shop_id).limit(amount.to_i - @coupons.count).where("coupons.id not in (?)", excluded_ids ) if @coupons.count < amount.to_i

    @coupons = (@coupons.sort_by{ |c| c.priority_score }).reverse
  end
end
