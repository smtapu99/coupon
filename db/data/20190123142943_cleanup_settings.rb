class CleanupSettings < ActiveRecord::Migration[5.2]
  def up
    Option.transaction do
      Site.all.each do |site|
        setting = site.try(:setting)
        next unless setting.present?

        setting.avoid_reload_routes = true

        setting.menu ||= {}

        if setting.publisher_site.present?
          # remove legacy
          [
            :show_home_link,
            :navigation_shop_ids,
            :footer_shop_ids,
            :footer_campaign_ids,
            :max_campaigns_in_nav,
            :navigation_category_ids
          ].each do |field|
            setting.publisher_site.delete_field(field) if setting.publisher_site.try(field).present?
          end
          setting.save
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
