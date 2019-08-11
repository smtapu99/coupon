class AddFieldToTags < ActiveRecord::Migration[5.2]
  def change
    add_column :tags, :site_id, :integer, index: true, after: :id
    add_column :tags, :category_id, :integer, index: true, after: :site_id
    add_column :tags, :api_hits, :integer, null: false, default: 0

    add_index :tags, [:site_id, :word]
  end
end
