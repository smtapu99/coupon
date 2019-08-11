class RemoveUnusedWidgets < ActiveRecord::Migration[5.2]
  def up
    widget_types = ['expiring_coupons', 'expired_coupon']
    Widget.where(name: widget_types).destroy_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
