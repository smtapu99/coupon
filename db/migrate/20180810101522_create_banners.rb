class CreateBanners < ActiveRecord::Migration[5.2]
  def change
    create_table :banners do |t|
      t.integer :site_id, null: false
      t.string :status, default: 'active'
      t.boolean :show_in_shops, default: false, null: false
      t.string :banner_type, default: 'general'
      t.text :value
      t.text :excluded_shop_ids
      t.datetime :start_date
      t.datetime :end_date
      t.timestamps
    end

    create_table :banner_locations do |t|
      t.integer :banner_id, null: false
      t.integer :bannerable_id, null: false
      t.string :bannerable_type, null: false
    end

    add_index :banners, [:site_id, :status]
    add_index :banner_locations, [:bannerable_id, :bannerable_type], name: 'bannerable_locations'
  end
end
