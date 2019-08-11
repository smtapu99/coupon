class AddAuthorizationToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :can_shops, :boolean, default: true, null: false, index: true, after: :role
    add_column :users, :can_coupons, :boolean, default: true, null: false, index: true, after: :can_shops
    add_column :users, :can_metas, :boolean, default: true, null: false, index: true, after: :can_coupons
  end
end
