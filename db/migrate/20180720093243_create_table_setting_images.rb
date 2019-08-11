class CreateTableSettingImages < ActiveRecord::Migration[5.0]
  def change
    create_table :image_settings do |t|
      t.integer :site_id
      t.string :favicon
      t.string :hero
      t.string :logo
      t.timestamps
    end

    add_index :image_settings, [:site_id]
  end
end
