class AddIsDirectClickoutToShops < ActiveRecord::Migration[5.2]
  def change
    add_column :shops, :is_direct_clickout, :boolean, null: false, default: false
  end
end
