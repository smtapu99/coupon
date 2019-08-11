class RemoveAdsFromSettings < ActiveRecord::Migration[5.2]
  def up
    WidgetBase.where(widget_type: 'ad').destroy_all
    WidgetBase.where(widget_type: 'ad_space').destroy_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
