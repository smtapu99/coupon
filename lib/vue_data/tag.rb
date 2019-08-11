module VueData
  class Tag < VueData::Base
    include Rails.application.routes.url_helpers

    private

    def records
      ::Tag.grid_filter(params)
    end

    def filters
      ::Tag.grid_filter_dropdowns
    end

    def records_paginated
      base = records.page(page).per(per_page)

      case order.to_sym
      when :category
        base.includes(:category).order("categories.name #{direction}")
      else
        base.order(order => direction)
      end
    end

    def data(record)
      {
        id: record.id,
        word: record.word,
        category: record.category.try(:name),
        is_blacklisted: record.is_blacklisted,
        api_hits: record.api_hits
      }
    end
  end
end
