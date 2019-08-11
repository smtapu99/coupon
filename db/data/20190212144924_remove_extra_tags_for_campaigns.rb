class RemoveExtraTagsForCampaigns < ActiveRecord::Migration[5.2]
  def up
    Campaign.where('tag_string LIKE ?', '%,%').each do |campaign|
      campaign.update_column :tag_string, campaign.tag_string.split(',').first.strip
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
