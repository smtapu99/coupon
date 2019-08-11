class AddNewTranslationKeyForEmptyShops < ActiveRecord::Migration[5.2]
  def up
    saocf_translations = Translation.where(key: 'SORRY_ALL_OUR_COUPONS_FOR')

    saocf_translations.each do |translation|
      ag_translation = Translation.where(locale: translation.locale, key: 'ARE_GONE').first
      next unless ag_translation.present?

      if translation.value.present? && ag_translation.value.present?
        new_value = translation.value + ' <b>{shop}</b> ' + ag_translation.value
      else
        new_value = nil
      end

      new_translation = Translation.create(key: 'SORRY_ALL_OUR_COUPONS_FOR_SHOP_ARE_GONE', value: new_value, locale: translation.locale)

      old_saocf_custom_translations = SiteCustomTranslation.where(translation_id: translation.id)
      old_ag_custom_translations = SiteCustomTranslation.where(translation_id: ag_translation.id)

      sites = old_saocf_custom_translations.map(&:site)

      if sites.present?
        sites.each do |site|
          old_saocf_custom_translation = site.site_custom_translations.where(translation_id: old_saocf_custom_translations.map(&:translation_id)).first
          old_ag_custom_translation = site.site_custom_translations.where(translation_id: old_ag_custom_translations.map(&:translation_id)).first

          if old_saocf_custom_translation.present? && old_ag_custom_translation.present?
            ct_value = old_saocf_custom_translation.value.strip + ' <b>{shop}</b> ' + old_ag_custom_translation.value.strip
            SiteCustomTranslation.create(site_id: site.id, translation_id: new_translation.id, value: ct_value)
          end
        end
      end


    end

  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
