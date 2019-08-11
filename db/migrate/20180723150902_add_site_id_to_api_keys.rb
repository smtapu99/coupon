class AddSiteIdToApiKeys < ActiveRecord::Migration[5.0]
  def change
    add_column :api_keys, :site_id, :integer, null: true, index: true
    change_column :api_keys, :user_id, :integer, null: true, index: true
  end
end

