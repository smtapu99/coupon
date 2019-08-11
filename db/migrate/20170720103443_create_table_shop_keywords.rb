class CreateTableShopKeywords < ActiveRecord::Migration[5.0]
  def change
    unless ActiveRecord::Base.connection.table_exists? :shop_keywords
      create_table :shop_keywords do |t|
        t.integer :site_id, null: false
        t.integer :shop_id, null: false
        t.string :kw1, default: nil
        t.string :kw2, default: nil
        t.string :kw3, default: nil
        t.string :kw4, default: nil
        t.string :kw5, default: nil
      end

      add_index :shop_keywords, [:id, :site_id, :shop_id]
    end
  end
end
