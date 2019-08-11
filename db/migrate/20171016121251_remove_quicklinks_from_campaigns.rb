class RemoveQuicklinksFromCampaigns < ActiveRecord::Migration[5.0]
  def change
    remove_column :html_documents, :quicklinks, :string
  end
end
