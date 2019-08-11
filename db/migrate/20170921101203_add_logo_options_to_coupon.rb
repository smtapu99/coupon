class AddLogoOptionsToCoupon < ActiveRecord::Migration[5.0]
  def change
    add_column :coupons, :use_logo_on_home_page, :boolean, default: false
    add_column :coupons, :use_logo_on_shop_page, :boolean, default: false
  end
end
