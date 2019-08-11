class CreateCategoryTags < ActiveRecord::Migration[5.2]
  def change
    create_table :category_tags do |t|
      t.belongs_to :category, index: true
      t.belongs_to :tag, index: true
      t.timestamps
    end

    add_index :category_tags, [:category_id, :tag_id], unique: true
  end
end
