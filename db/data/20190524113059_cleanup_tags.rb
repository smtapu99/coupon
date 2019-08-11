class CleanupTags < ActiveRecord::Migration[5.2]
  def up
    # multiply blacklisted tags to all sites of countries
    Country.all.each do |country|
      country.tags.where(is_blacklisted: true).each do |tag|
        country.sites.active.each do |site|
          tag = Tag.find_or_initialize_by(country_id: site.country_id, word: tag.word, is_blacklisted: true)
          tag.site_id = site.id
          tag.save
        end
      end
    end

    # attach site_id to tags of existing category_tag matches
    execute('UPDATE tags INNER JOIN category_tags ON category_tags.tag_id = tags.id SET tags.category_id = category_tags.category_id')
    execute('UPDATE tags INNER JOIN categories ON categories.id = tags.category_id SET tags.site_id = categories.site_id')

    # execute('DELETE FROM tags WHERE site_id is null')
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
