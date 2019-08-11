class AddIsWlsToSites < ActiveRecord::Migration[5.0]
  def change
    add_column :sites, :is_wls, :boolean, after: :is_multisite, default: 0, null: false, index: true#
  end
end
