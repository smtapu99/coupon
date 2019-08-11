class RemoveUnusedFieldsAndTables < ActiveRecord::Migration[5.0]
  def up
    remove_column :shop_imports, :site_id, :integer if column_exists?(:shop_imports, :site_id)
    remove_column :coupon_imports, :site_id, :integer  if column_exists?(:coupon_imports, :site_id)
    drop_table :routes_changed_timestamp
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
