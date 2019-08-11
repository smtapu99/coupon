class Widgets::PremiumOffersService < Widgets::BaseService

  private

  def load_widget_data
    @rows = []

    if @widget.value[:premium_offer_rows].present?
      # rows
      @widget.value[:premium_offer_rows].each do |row|
        # widgets
        row.last[:widgets].each do |widget|
          coupon_ids = widget[:coupon_id].gsub(' ', '').split(',')
          if coupon_ids.present?
            widget[:coupon] = @site.coupons
              .where(id: coupon_ids)
              .order(Arel.sql('find_in_set(coupons.id, "' + coupon_ids.join(',') + '")'))
              .first
          end
        end
        @rows << row
      end
    end
  end
end
