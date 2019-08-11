module VueData
  class User < VueData::Base
    private

    def records
      ::User.grid_filter(params)
    end

    def data(record)
      {
        status: record.status,
        id: record.id,
        first_name: record.first_name,
        last_name: record.last_name,
        email: record.email,
        role: record.role
      }
    end
  end
end
