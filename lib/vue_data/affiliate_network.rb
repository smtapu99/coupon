module VueData
  class AffiliateNetwork < VueData::Base
    private

    def records
      ::AffiliateNetwork.grid_filter(params)
    end

    def data(record)
      {
        id: record.id,
        status: record.status,
        name: record.name,
        slug: record.slug
      }
    end
  end
end
