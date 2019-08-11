class ChangeCanQaAndCanWidgetsForUsersToFalse < ActiveRecord::Migration[5.2]
  def up
    User.update_all(can_qa: false)
    User.update_all(can_widgets: false)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
