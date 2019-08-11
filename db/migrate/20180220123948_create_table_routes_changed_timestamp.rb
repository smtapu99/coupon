class CreateTableRoutesChangedTimestamp < ActiveRecord::Migration[5.0]
  def change
    create_table :routes_changed_timestamp do |t|
      t.integer :timestamp, null: false, default: 0
    end
  end
end
