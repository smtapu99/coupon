class MigrateImageSettings < ActiveRecord::Migration[5.0]
  def self.up
    # give em all an ImageSetting to avoid issues with presence
    Site.all.each do |site|
      ImageSetting.find_or_create_by(site_id: site)
    end

    # migrate images only on active sites
    Site.active.each do |site|
      next unless site.try(:setting).try(:image_upload).present? || site.favicon_url.present?
      image_setting = ImageSetting.find_or_create_by(site_id: site.id)

      image_upload = site.try(:setting).try(:image_upload)
      site.setting.avoid_reload_routes = true
      if image_upload.present?
        image_setting.remote_logo_url = sanitize_https(image_upload.logo_url) if image_upload.logo_url.present?
        image_setting.remote_hero_url = sanitize_https(image_upload.flat_2016_hero_url) if image_upload.flat_2016_hero_url.present?
        image_setting.remote_favicon_url = sanitize_https(image_upload.favicon_url) if image_upload.favicon_url.present? && !site.favicon_url.present?
      end

      if site.favicon_url.present?
        image_setting.remote_favicon_url = site.favicon_url
      end

      if !image_setting.save
        p image_setting.errors.inspect
      end
    end
  end

  def self.sanitize_https(value)
    (value.start_with?('//') ? 'https:' + value : value)
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
