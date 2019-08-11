class RemoveShowNavLinkFromCampaigns < ActiveRecord::Migration[5.2]
  def change
    remove_column :campaigns, :show_nav_link
  end
end
