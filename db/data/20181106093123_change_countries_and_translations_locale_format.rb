class ChangeCountriesAndTranslationsLocaleFormat < ActiveRecord::Migration[5.2]
  LOCALES = {
    'en_GB' => 'en-GB',
    'en_US' => 'en-US',
    'de_DE' => 'de-DE',
    'es_CL' => 'es-CL',
    'es_CO' => 'es-CO',
    'es_ES' => 'es-ES',
    'es_MX' => 'es-MX',
    'fr_FR' => 'fr-FR',
    'it_IT' => 'it-IT',
    'nl_NL' => 'nl-NL',
    'pt_BR' => 'pt-BR',
    'pl_PL' => 'pl-PL',
    'ru_RU' => 'ru-RU',
    'ru_UA' => 'ru-UA',
    'tr_TR' => 'tr-TR'
  }

  def up
    LOCALES.each do |old, new|
      update_countries_and_translations_locale_format(old, new)
    end
  end

  def down
    LOCALES.each do |old, new|
      update_countries_and_translations_locale_format(new, old)
    end
  end

  private

  def update_countries_and_translations_locale_format(old, new)
    Country.where(locale: old).update_all(locale: new)
    Translation.where(locale: old).update_all(locale: new)
  end
end
