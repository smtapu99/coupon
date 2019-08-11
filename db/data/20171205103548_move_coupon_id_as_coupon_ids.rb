class MoveCouponIdAsCouponIds < ActiveRecord::Migration[5.0]
  def self.up
    widgets = Widget.where(name: 'hot_offers')

    if widgets.present?

      widgets.each do |widget|
        next unless widget.value[:hot_offers].present?

        widget.value[:hot_offers].each do |hot_offer|
          next if hot_offer[:coupon_id].nil?
          hot_offer[:coupon_ids] = hot_offer[:coupon_id].to_s
          hot_offer.delete('coupon_id')
        end
        widget.save
      end

    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
