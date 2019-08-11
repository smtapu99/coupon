class RemoveShowFbCommentsFromSiteSettings < ActiveRecord::Migration[5.0]
  def self.up
    Site.all.each do |site|
      if site.try(:setting).try(:publisher_site).try(:show_fb_comments).present?
        puts 'remove show_fb_comments setting from site: ' + site.id.to_s
        site.setting.avoid_reload_routes = true
        site.setting.publisher_site.delete_field(:show_fb_comments)
        site.setting.save
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
