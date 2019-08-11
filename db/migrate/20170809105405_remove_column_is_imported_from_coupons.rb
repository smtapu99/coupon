class RemoveColumnIsImportedFromCoupons < ActiveRecord::Migration[5.0]
  def change
    remove_column :coupons, :is_imported, :boolean

    change_column :coupons, :status, :string, null: false, default: 'active'
  end
end
