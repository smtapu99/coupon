class AddStatusToSites < ActiveRecord::Migration[5.0]
  def change
    add_column :sites, :status, :string, after: :id, default: 'active'
    add_index :sites, [:hostname, :status, :is_multisite, :subdir_name], name: 'sites_main_index'
    remove_index :sites, [:hostname, :is_multisite, :subdir_name]
  end
end
