class RemoveSiteIdFromCampaignImport < ActiveRecord::Migration[5.0]
  def change
    remove_column :campaign_imports, :site_id, :integer
  end
end
