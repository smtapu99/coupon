class RemoveDoubleOptinOptionFromSettings < ActiveRecord::Migration[5.0]
  def self.up
    Site.all.each do |site|
      next unless site.try(:setting).try(:newsletter).try(:double_optin).present?
      p 'deleting double_optin setting for site: ' + site.hostname
      site.setting.avoid_reload_routes = true
      site.setting.newsletter.delete_field(:double_optin)
      site.setting.save
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
