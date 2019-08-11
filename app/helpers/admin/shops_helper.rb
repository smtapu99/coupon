module Admin
  module ShopsHelper
    def cache_key_for_site_current_shops
      count = Site.current.shops.count
      max_updated_at = Site.current.shops.maximum(:updated_at).try(:utc).try(:to_s, :number)
      "site_current_shops/all-#{count}-#{max_updated_at}"
    end

    def cache_key_for_related_current_shops
      count = Relation.count
      max_updated_at = Relation.maximum(:updated_at).try(:utc).try(:to_s, :number)
      "site_current_related_shops/all-#{count}-#{max_updated_at}"
    end
  end
end
