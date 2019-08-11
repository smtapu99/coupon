class CreateTableProblems < ActiveRecord::Migration[5.0]
  def change
    unless ActiveRecord::Base.connection.table_exists? :problems
      create_table :problems do |t|
        t.integer :user_id
        t.string :model
        t.string :column
        t.text :value
        t.text :message
        t.integer :solved_by
        t.datetime :solved_at
        t.timestamps
      end
    end
  end
end
