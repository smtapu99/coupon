class ChangeDefaultValuesForCanQaAndCanWidgets < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :can_widgets, :boolean, default: false
    change_column :users, :can_qa, :boolean, default: false
  end
end
