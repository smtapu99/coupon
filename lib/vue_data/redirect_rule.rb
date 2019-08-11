module VueData
  class RedirectRule < VueData::Base
    private

    def records
      ::RedirectRule::grid_filter(params)
    end

    def data(record)
      {
        id: record.id,
        active: record.active,
        source: record.source,
        destination: record.destination
      }
    end
  end
end