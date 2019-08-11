module VueData
  class Campaign < VueData::Base
    private

    def records
      ::Campaign.grid_filter(params)
    end

    def records_paginated
      base = records.page(page).per(per_page)

      case order.to_sym
      when :parent
        base.includes(:parent).order("parents_campaigns.name #{direction}")
      when :shop
        base.includes(:shop).order("shops.title #{direction}")
      else
        base.order(order => direction)
      end
    end


    def data(record)
      {
        id: record.id,
        is_root_campaign: record.is_root_campaign,
        status: record.status,
        name: record.name,
        slug: record.slug,
        parent: record.parent_name,
        shop: record.shop_title,
        blog_feed_url: record.blog_feed_url,
        start_date: (record.start_date.to_s(:db) rescue ''),
        end_date: (record.end_date.to_s(:db) rescue '')
      }
    end
  end
end
