class ExcludeJqueryFromAbc < ActiveRecord::Migration[5.0]
  def self.up
    site = Site.find_by_id 31 #abc

    if site.present?
      site.setting.publisher_site.disable_jquery = '1'
      site.setting.save
    end

  end

  def self.down
    site = Site.find_by_id 31 #abc

    if site.present?
      site.setting.publisher_site.disable_jquery = '0'
      site.setting.save
    end

  end
end
