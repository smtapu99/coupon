module VueData
  class Country < VueData::Base
    private

    def records
      ::Country.grid_filter(params)
    end

    def data(record)
      {
        id: record.id,
        name: record.name,
        locale: record.locale
      }
    end
  end
end
