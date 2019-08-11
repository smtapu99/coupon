class DropTableNewsletterSubscribers < ActiveRecord::Migration[5.0]
  def up
    drop_table :newsletter_subscribers
    drop_table :newsletter_subscriber_shops
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
