class RemoveDataSecurityUrlFromSettings < ActiveRecord::Migration[5.0]
  def self.up
    Site.all.each do |site|
      next unless site.try(:setting).try(:legal_pages).try(:data_security_url).present?
      site.setting.avoid_reload_routes = true
      site.setting.legal_pages.delete_field(:data_security_url)
      site.setting.save
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
