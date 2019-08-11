class UpdateIsCriticalInAlerts < ActiveRecord::Migration[5.2]
  def up
    Alert.where(alert_type: 'coupons_expiring').update_all(is_critical: true)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
