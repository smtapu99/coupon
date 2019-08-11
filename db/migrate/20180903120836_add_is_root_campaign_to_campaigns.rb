class AddIsRootCampaignToCampaigns < ActiveRecord::Migration[5.2]
  def change
    add_column :campaigns, :is_root_campaign, :boolean, after: :is_imported, index: true, default: false, null: false
  end
end
