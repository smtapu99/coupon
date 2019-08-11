class AddIsCriticalToAlerts < ActiveRecord::Migration[5.2]
  def change
    add_column :alerts, :is_critical, :boolean, after: :solved_by_id, default: false, index: true
  end
end
