class AddCanQaAndCanWidgetsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :can_widgets, :boolean, default: true, null: false, index: true, after: :can_metas
    add_column :users, :can_qa, :boolean, default: true, null: false, index: true, after: :can_widgets
  end
end
