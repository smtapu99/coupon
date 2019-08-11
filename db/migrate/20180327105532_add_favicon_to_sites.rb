class AddFaviconToSites < ActiveRecord::Migration[5.0]
  def change
    add_column :sites, :favicon, :string, after: :time_zone
  end
end
