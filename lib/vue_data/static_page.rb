module VueData
  class StaticPage < VueData::Base
    private

    def records
      ::StaticPage.grid_filter(params)
    end

    def records_paginated
      base = records.page(page).per(per_page)

      case order.to_sym
      when :site
        base.includes(:site).order("sites.hostname #{direction}")
      else
        base.order(order => direction)
      end
    end

    def data(record)
      {
        id: record.id,
        status: record.status,
        site: record.site.hostname,
        title: record.title,
        slug: record.slug
      }
    end
  end
end
