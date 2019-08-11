class ChangeSearchTranslationVariables < ActiveRecord::Migration[5.2]
  def up
    translations = Translation.where(key: 'META_TITLE_SEARCH_PAGE')
    custom_translations = SiteCustomTranslation.where(translation_id: translations&.map(&:id))

    custom_translations.each do |t|
      t.value.gsub!('{query}', '{search_query}')
      t.value.gsub!('{searchterm}', '{search_query}')
      t.save
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
