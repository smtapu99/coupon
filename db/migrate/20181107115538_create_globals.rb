class CreateGlobals < ActiveRecord::Migration[5.2]
  def change
    create_table :globals do |t|
      t.string :name, null: false
      t.string :model_type, null: false

      t.timestamps
    end

    add_index :globals, [:name, :model_type], unique: true
  end
end
