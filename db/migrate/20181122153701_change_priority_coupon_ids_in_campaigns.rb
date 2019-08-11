class ChangePriorityCouponIdsInCampaigns < ActiveRecord::Migration[5.2]
  def change
    change_column :campaigns, :priority_coupon_ids, :text
  end
end
