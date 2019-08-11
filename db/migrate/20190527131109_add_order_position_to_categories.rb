class AddOrderPositionToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :order_position, :integer, default: 0, null: false, after: :site_id
  end
end
