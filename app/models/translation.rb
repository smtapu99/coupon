class Translation < ApplicationRecord
  has_one :site_custom_translation, -> { where site_id: Site.current.blank? ? nil : Site.current.id }, dependent: :destroy
  has_one :unscoped_site_custom_translation, class_name: 'SiteCustomTranslation', foreign_key: :translation_id
  accepts_nested_attributes_for :site_custom_translation, update_only: true

  after_find :customize
  after_commit :clear_cache

  validates_presence_of :key
  validates_presence_of :locale

  scope :by_locale, ->(locale) { where(locale: locale) }
  scope :by_search_query, ->(query) { where("translations.key like :query OR translations.value like :query", { query: "%#{query}%" }) }
  scope :without_site_custom_translation, -> {
    left_outer_joins(:unscoped_site_custom_translation).where(site_custom_translations: { translation_id: nil })
  }
  scope :by_site, ->(site) {
    by_locale(site.country.locale).
      without_site_custom_translation.
      or(left_outer_joins(:unscoped_site_custom_translation).where(site_custom_translations: { site: site.id }))
  }

  def self.distinct_keys
    raise 'Invalid Site' unless Site.current.present?

    locale = Site.current.country.locale
    allowed_keys = SiteCustomTranslation.joins(:translation).where(site_id: 58).pluck(:key)

    translations = Translation.where(locale: locale)
    translations = translations.where(key: allowed_keys) if allowed_keys.present?
    translations.map do |translation|
      [
        translation.key,
        SiteCustomTranslation.find_by(translation_id: translation.id, site_id: Site.current.id).try(:value)
      ]
    end
  end

  private

  def customize
    if Site.current.present?
      custom_entity = site_custom_translation
      return unless custom_entity.present?

      self.assign_attributes(custom_entity.attributes.reject{ |k| unwanted_custom_attributes.include? k })
    end
  end

  def unwanted_custom_attributes
  [
    'id',
    'site_id',
    'translation_id',
    'updated_at',
    'created_at'
  ]
  end

  def clear_cache
    I18n.backend.clear_cache_key(locale, key)
  end
end
