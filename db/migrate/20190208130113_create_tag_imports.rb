class CreateTagImports < ActiveRecord::Migration[5.2]
  def change
    create_table :tag_imports do |t|
      t.integer :site_id, null: false, index: true
      t.string :status, default: "pending", index: true
      t.text :error_messages
      t.string :file
      t.timestamp
    end
  end
end
