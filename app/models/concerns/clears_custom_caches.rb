module ClearsCustomCaches
  extend ActiveSupport::Concern

  included do
    # Write here caches of the frontend which should be cleared
    # if any of the containing models changes
    #
    def clear_frontend_caches
      site_id = if self.respond_to?('site_id')
        self.site_id
      elsif Site.current.present?
        Site.current.id
      end
      if site_id.present?
        Rails.cache.delete([site_id, 'shop_category_slugs'])
        # put more caches here if necessary ...
      end
    end
  end
end
