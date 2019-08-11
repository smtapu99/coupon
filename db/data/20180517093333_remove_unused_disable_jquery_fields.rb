class RemoveUnusedDisableJqueryFields < ActiveRecord::Migration[5.0]
  def self.up
    Site.all.each do |site|
      if site.try(:setting).try(:publisher_site).try(:disable_jquery).present?
        site.setting.publisher_site.delete_field(:disable_jquery)
        site.setting.save
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
