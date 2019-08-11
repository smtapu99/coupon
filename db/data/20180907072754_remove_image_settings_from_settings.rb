class RemoveImageSettingsFromSettings < ActiveRecord::Migration[5.2]
  def up
    Site.active.each do |site|
      if site.try(:setting).try(:image_upload).present?
        puts 'remove image_uplaod setting from site: ' + site.id.to_s
        site.setting.avoid_reload_routes = true
        site.setting.value.delete_field(:image_upload)
        site.setting.save
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
