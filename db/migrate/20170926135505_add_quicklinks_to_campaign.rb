class AddQuicklinksToCampaign < ActiveRecord::Migration[5.0]
  def change
    add_column :html_documents, :quicklinks, :string
  end
end
