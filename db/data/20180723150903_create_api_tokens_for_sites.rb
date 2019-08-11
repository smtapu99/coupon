class CreateApiTokensForSites < ActiveRecord::Migration[5.0]
  def self.up
    Site.active.each do |site|
      ApiKey.find_or_create_by(site_id: site.id)
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
