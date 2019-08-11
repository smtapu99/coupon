class GlobalShopMapping < ActiveRecord::Migration[5.2]
  def change
    create_table :global_shop_mappings do |t|
      t.belongs_to :global, index: true
      t.belongs_to :country, index: true
      t.string :url_home
      t.string :domain
      t.timestamps
    end
  end
end
