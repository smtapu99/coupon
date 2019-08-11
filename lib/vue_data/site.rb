module VueData
  class Site < VueData::Base
    private

    def records
      ::Site.grid_filter(params)
    end

    def records_paginated
      base = records.page(page).per(per_page)

      case order.to_sym
      when :country
        base.includes(:country).order("countries.name #{direction}")
      else
        base.order(order => direction)
      end

    end

    def data(record)
      {
        id: record.id,
        status: record.status,
        name: record.name,
        hostname: record.hostname,
        time_zone: record.time_zone,
        country: record.country.name,
      }
    end
  end
end
