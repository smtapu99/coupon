module VueData
  class Shop < VueData::Base
    private

    def records
      ::Shop.grid_filter(params)
    end

    def data(record)
      {
        id: record.id,
        tier_group: record.tier_group,
        status: record.status,
        title: record.title,
        slug: record.slug,
        is_top: record.is_top,
        is_hidden: record.is_hidden,
        priority_score: record.priority_score,
        updated_at: record.updated_at.to_s(:db)
      }
    end
  end
end
