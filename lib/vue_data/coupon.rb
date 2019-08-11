module VueData
  class Coupon < VueData::Base
    private

    def records
      ::Coupon.grid_filter(params)
    end

    def records_paginated
      base = records.includes(:affiliate_network, :shop).page(page).per(per_page)

      case order.to_sym
      when :affiliate_network_slug
        base.includes(:affiliate_network).order("affiliate_networks.slug #{direction}")
      when :shop_slug
        base.includes(:shop).order("shops.slug #{direction}")
      when :expired
        base.order("end_date #{direction}")
      else
        base.order(order => direction)
      end
    end

    def data(record)
      {
        id: record.id,
        status: record.status,
        title: record.title,
        affiliate_network_slug: record.affiliate_network_slug,
        shop_slug: record.shop.slug,
        code: record.code,
        is_top: record.is_top,
        is_exclusive: record.is_exclusive,
        is_free: record.is_free,
        start_date: (record.start_date.to_s(:db) rescue  ''),
        end_date: (record.end_date.to_s(:db) rescue  ''),
        created_at: (record.created_at.to_s(:db) rescue  ''),
        priority_score: record.priority_score,
        expired: record.has_expired?
      }
    end
  end
end
