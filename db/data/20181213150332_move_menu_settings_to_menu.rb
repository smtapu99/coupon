class MoveMenuSettingsToMenu < ActiveRecord::Migration[5.2]
  def up
    Option.transaction do
      Site.all.each do |site|
        setting = site.try(:setting)
        next unless setting.present?

        setting.avoid_reload_routes = true

        setting.menu ||= {}
        campaign_limit = 1

        # migrate existing settings
        if setting.publisher_site.present?
          campaign_limit = setting.publisher_site.max_campaigns_in_nav if setting.publisher_site.max_campaigns_in_nav.present?

          setting.menu.show_home_link = setting.publisher_site.show_home_link if setting.publisher_site.show_home_link.present?
          setting.menu.navigation_shop_ids = setting.publisher_site.navigation_shop_ids if setting.publisher_site.navigation_shop_ids.present?
          setting.menu.footer_shop_ids = setting.publisher_site.footer_shop_ids if setting.publisher_site.footer_shop_ids.present?
          setting.menu.footer_campaign_ids = setting.publisher_site.footer_campaign_ids if setting.publisher_site.footer_campaign_ids.present?

          # remove legacy settings
          # [:show_home_link, :navigation_shop_ids, :footer_shop_ids, :footer_campaign_ids, :max_campaigns_in_nav].each do |field|
          #   setting.publisher_site.delete_field(field) if setting.publisher_site.try(field).present?
          # end
        end

        # set campaign ids
        campaign_ids = site.campaigns.active
          .includes(:parent)
          .where(show_nav_link: true)
          .where('campaigns.template != ?', 'sem')
          .order(created_at: :desc)
          .limit(campaign_limit)
          .pluck(:id)
        setting.menu.main_campaign_ids = campaign_ids if campaign_ids.present?

        # site based customization
        if site.id == 75
          setting.menu.main_shop_ids = [24952, 24939, 24955]
        end
        if site.id == 64
          setting.menu.main_shop_ids = [22842]
        end
        if site.id == 50
          setting.menu.show_categories = 0
          setting.menu.main_shop_ids = [18746]
        end

        setting.save
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
