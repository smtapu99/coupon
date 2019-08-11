I18n.class_eval do
  mattr_accessor :global_scope, :translations_timestamp, :shop_scope
end

class I18n::Backend::Simple
  module Implementation

    def localize(*args)
      current_scope, I18n.global_scope = I18n.global_scope, :backend
      result, I18n.global_scope = super, current_scope
      result
    end

    def simple_lookup(locale, key, scope = [], options = {})
      init_translations unless initialized?
      keys = I18n.normalize_keys(locale, key, scope, options[:separator])
      keys.inject(translations) do |result, _key|
        _key = _key.to_sym
        return nil unless result.is_a?(Hash) && result.has_key?(_key)
        result = result[_key]
        result = resolve(locale, _key, result, options.merge(:scope => nil)) if result.is_a?(Symbol)
        result
      end
    end

    # use @cached to avoid duplicate lookups in the cache
    def lookup(locale, key, scope = [], options = {})
      init_or_reset_cache
      return simple_lookup(locale, key, scope, options) unless is_frontend?

      if I18n.shop_scope.present?
        translation = shop_scoped_translation(locale, key)
        return translation if translation.present?
      end

      unscoped_translation(locale, key)
    end

    def init_or_reset_cache
      if Thread.current[:translations_timestamp].present? && Thread.current[:translations_timestamp] != I18n.translations_timestamp
        @cached = {}
        Thread.current[:translations_timestamp] = I18n.translations_timestamp
      else
        @cached ||= {}
      end
    end

    def clear_cache_key(locale, key)
      cache_key = lookup_key(locale, key)
      @cached.delete(cache_key) if @cached
      Rails.cache.delete(cache_key)
    end

    private

    def unscoped_translation(locale, key)
      cache_key = lookup_key(locale, key)
      return @cached[cache_key] if @cached[cache_key].present?

      fetch_cached(cache_key, locale, key)
    end

    def shop_scoped_translation(locale, key)
      scoped_key = "#{I18n.shop_scope}_#{key}"
      scoped_cache_key = lookup_key(locale, scoped_key)
      return @cached[scoped_cache_key] if @cached[scoped_cache_key].present?

      fetch_cached(scoped_cache_key, locale, scoped_key)
    end

    def fetch_cached(cache_key, locale, key)
      Rails.cache.fetch(cache_key) do
        ActiveRecordHelper::retry_lock_error(3) do
          translation = Translation.find_by(locale: [locale.to_s, locale.to_s.sub('_', '-')], key: key.to_s)&.value
          # XXX: custom solution for shops, e.g. Apple. Check also shop_controller.rb
          if translation.blank? && !I18n.shop_scope.present?
            translation = Translation.find_or_create_by(locale: locale.to_s.sub('_', '-'), key: key.to_s).value
          end

          @cached[cache_key] = translation if translation.present?
          translation
        end
      end
    end

    def lookup_key(locale, key)
      [Site.current ? Site.current.id : 'default', locale.to_s, key.to_s]
    end

    def is_frontend?
      I18n.global_scope == :frontend
    end
  end
end
