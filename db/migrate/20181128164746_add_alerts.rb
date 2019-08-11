class AddAlerts < ActiveRecord::Migration[5.2]
  def change
    create_table :alerts do |t|
      t.references :alertable, polymorphic: true
      t.integer :site_id
      t.string :alert_type, null: false
      t.string :status, null: false, default: 'active'
      t.text :message
      t.integer :solved_by_id
      t.datetime :solved_at
      t.timestamps
    end

    add_index :alerts, [:site_id, :alertable_id, :alertable_type, :alert_type], name: 'alertable_index'
  end
end
