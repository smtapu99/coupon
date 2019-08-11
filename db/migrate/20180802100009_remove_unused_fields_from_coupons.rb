class RemoveUnusedFieldsFromCoupons < ActiveRecord::Migration[5.2]
  def up
    remove_column :coupons, :mini_title
    remove_column :coupons, :ranking_value
    remove_column :coupons, :commission_value
    remove_column :coupons, :commission_type
    remove_column :coupons, :logo_color
    remove_column :coupons, :coupon_of_the_week
    remove_column :coupons, :is_international
    remove_column :coupons, :tracking_platform_campaign_id
    remove_column :coupons, :tracking_platform_banner_id
    remove_column :coupons, :old_url
    remove_column :coupons, :shop_slider_position
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
