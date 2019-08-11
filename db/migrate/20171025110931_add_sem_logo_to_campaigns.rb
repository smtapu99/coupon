class AddSemLogoToCampaigns < ActiveRecord::Migration[5.0]
  def change
    add_column :campaigns, :sem_background_url, :string, after: :priority_coupon_ids
    add_column :campaigns, :sem_logo_url, :string, after: :priority_coupon_ids
  end
end
