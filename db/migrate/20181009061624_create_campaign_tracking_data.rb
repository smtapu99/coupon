class CreateCampaignTrackingData < ActiveRecord::Migration[5.2]
  def change
    create_table :campaign_tracking_data do |t|
      t.belongs_to :tracking_click
      t.text :data
      t.timestamps
    end
  end
end
