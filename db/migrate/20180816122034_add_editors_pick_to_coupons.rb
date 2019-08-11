class AddEditorsPickToCoupons < ActiveRecord::Migration[5.2]
  def change
    add_column :coupons, :is_editors_pick, :boolean, after: :is_exclusive, index: true, null: false, default: false
  end
end
