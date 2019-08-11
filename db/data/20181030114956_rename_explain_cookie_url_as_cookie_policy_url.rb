class RenameExplainCookieUrlAsCookiePolicyUrl < ActiveRecord::Migration[5.2]
  def up
    Site.all.each do |site|
      setting = site.try(:setting)
      next unless setting.try(:admin_rules).present?

      setting.avoid_reload_routes = true
      puts 'rename explain_cookie_url setting from site: ' + site.id.to_s
      if setting.admin_rules.try(:explain_cookie_url).present?
        setting.admin_rules[:cookie_policy_url] = setting.admin_rules.explain_cookie_url
        setting.admin_rules.delete_field(:explain_cookie_url)
      end
      setting.admin_rules.delete_field(:show_cookie_law_message) if setting.admin_rules.show_cookie_law_message.present?
      setting.save
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
