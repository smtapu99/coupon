class Widgets::PremiumHeroService < Widgets::BaseService

  private

  def load_widget_data
    @error = false
    @premium_hero = []

    @widget.value[:premium_hero].each do |offer|
      next unless offer[:coupon_ids].present? || offer[:coupon_id].present?

      if offer[:coupon_id].present?
        coupon = @site.coupons.find_by_id offer[:coupon_id]
      else
        coupon_ids = offer[:coupon_ids]
        coupon = @site.coupons.active
          .joins(:shop)
          .includes(:shop)
          .visible
          .where(id: coupon_ids.split(','))
          .order('find_in_set(coupons.id, "' + coupon_ids + '")').first
      end

      offer[:coupon] = coupon
      @premium_hero << offer

      unless coupon.present?
        @error = true
        return
      end

    end

  end
end
