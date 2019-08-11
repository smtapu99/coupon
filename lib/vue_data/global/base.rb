module VueData
  class Global::Base < VueData::Base
    private

    def records
      ::Global.grid_filter(params)
    end

    def data(record)
      {
        id: record.id,
        name: record.name,
        model_type: record.model_type
      }
    end
  end
end
