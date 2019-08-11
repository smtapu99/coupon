module VueData
  class Banner < VueData::Base
    private

    def records
      ::Banner.grid_filter(params)
    end

    def data(record)
      {
        id: record.id,
        name: record.name,
        status: record.status,
        image_url: record.image_url,
        banner_type: record.banner_type,
        theme: record.theme,
        start_date: (record.start_date.to_date.to_s(:db) rescue ''),
        end_date: (record.end_date.to_date.to_s(:db) rescue '')
      }
    end
  end
end
