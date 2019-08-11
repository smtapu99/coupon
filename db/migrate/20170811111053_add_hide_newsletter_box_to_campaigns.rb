class AddHideNewsletterBoxToCampaigns < ActiveRecord::Migration[5.0]
  def change
    add_column :campaigns, :hide_newsletter_box, :boolean, default: false
  end
end
