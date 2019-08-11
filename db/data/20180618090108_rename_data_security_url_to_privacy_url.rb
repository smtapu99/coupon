class RenameDataSecurityUrlToPrivacyUrl < ActiveRecord::Migration[5.0]
  def self.up
    Site.all.each do |site|
      next unless site.try(:setting).try(:legal_pages).try(:data_security_url).present?
      puts 'duplicate data_security_url to privacy_policy_url for: ' + site.id.to_s
      site.setting.avoid_reload_routes = true
      site.setting.legal_pages.privacy_policy_url = site.setting.legal_pages.data_security_url
      site.setting.save
    end

    #TODO: remove data_security_url after successfull deploy
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
