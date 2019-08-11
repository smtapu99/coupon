class MoveNavigationCategoryIds < ActiveRecord::Migration[5.2]
  def up
    Option.transaction do
      Site.all.each do |site|
        setting = site.try(:setting)
        next unless setting.present?

        setting.avoid_reload_routes = true

        setting.menu ||= {}

        # migrate existing settings
        if setting.publisher_site.present?
          setting.menu.navigation_category_ids = setting.publisher_site.navigation_category_ids if setting.publisher_site.navigation_category_ids.present?

          # [:show_home_link, :navigation_shop_ids, :footer_shop_ids, :footer_campaign_ids, :max_campaigns_in_nav, :navigation_category_ids].each do |field|
          #   setting.publisher_site.delete_field(field) if setting.publisher_site.try(field).present?
          # end
        end

        setting.save
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
