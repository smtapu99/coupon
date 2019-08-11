class UpdateCampaignTemplatesDefaults < ActiveRecord::Migration[5.0]
  def self.up
    Campaign.where(template: 'themed--xmas').update_all(template: 'themed--default')
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
