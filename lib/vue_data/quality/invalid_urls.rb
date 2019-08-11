module VueData
  class Quality::InvalidUrls < VueData::Quality
    include Rails.application.routes.url_helpers

    private

    def records
      ::Coupon::invalid_urls_filter(params)
    end

    def data(record)
      {
        id: record.id,
        edit_path: edit_admin_coupon_path(record),
        shop_slug: record.shop_slug,
        affiliate_network_slug: record.affiliate_network_slug,
        url: record.url
      }
    end
  end
end
