module VueData
  class Category < VueData::Base
    private

    def records
      ::Category.grid_filter(params)
    end

    def records_paginated
      base = records.page(page).per(per_page)

      case order.to_sym
      when :parent
        base.joins(:parent).order("parents_categories.name #{direction}")
      else
        base.order(order => direction)
      end
    end

    def data(record)
      {
        id: record.id,
        status: record.status,
        name: record.name,
        slug: record.slug,
        main_category: record.main_category,
        parent: record.parent_name
      }
    end
  end
end
