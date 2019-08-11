class PrepareSiteService

  def self.call to_site, from_site, truncate_if_exists = false

    raise 'Invalid Site' unless to_site.is_a?(Site) && from_site.is_a?(Site)

    @from_site = from_site
    @to_site = to_site

    if truncate_if_exists
      truncated = truncate_translations && truncate_categories && truncate_routes

      raise 'Error: was not able to truncate translations, categories or routes while creating site' + @to_site.id.to_s unless truncated
    end

    return copy_translations && copy_categories && copy_routes
  end

  def self.truncate_translations
    sql = "DELETE FROM site_custom_translations where site_id = #{@to_site.id}";
    ActiveRecord::Base.connection.execute(sql).nil?
  end

  def self.truncate_categories
    sql = "DELETE FROM categories where site_id = #{@to_site.id}";
    ActiveRecord::Base.connection.execute(sql).nil?
  end

  def self.truncate_routes
    return true unless @to_site.setting.present?

    @to_site.setting.value[:routes] = nil
    return @to_site.setting.save
  end

  def self.copy_translations
    sql = "INSERT INTO site_custom_translations (site_id, translation_id, value, created_at, updated_at) SELECT #{@to_site.id} AS site_id, translation_id, value, NOW(), NOW() FROM site_custom_translations WHERE site_id = #{@from_site.id}";
    ActiveRecord::Base.connection.execute(sql).nil?
  end

  def self.copy_categories
    Category.where(site_id: @from_site.id).active.each do |from_cat|
      to_cat = from_cat.dup
      to_cat.site_id = @to_site.id
      to_cat.html_document = from_cat.html_document.dup
      to_cat.save
    end
  end

  def self.copy_routes
    return unless @from_site.setting.present?
    @to_site.setting ||= Setting.new

    @to_site.setting.value[:routes] = @from_site.setting.value[:routes]
    return @to_site.setting.save
  end

end
