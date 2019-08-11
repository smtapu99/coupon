class DeleteColumnsAndTables < ActiveRecord::Migration[5.0]
  def up
    remove_column :shops, :logo_cropped, :string
    drop_table :site_custom_categories
    drop_table :site_custom_shops
    drop_table :site_custom_coupons
    drop_table :site_status_coupons
    drop_table :site_status_shops
    drop_table :site_status_categories
  end

  def down

  end
end
