class AddCouponsOnTopToCampaigns < ActiveRecord::Migration[5.2]
  def change
    add_column :campaigns, :coupons_on_top, :boolean, default: false
  end
end
