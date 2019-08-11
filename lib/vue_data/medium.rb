module VueData
  class Medium < VueData::Base
    private

    def records
      ::Medium.grid_filter(params)
    end

    def data(record)
      {
        id: record.id,
        file_name: record.file_name.url,
        thumbnail: record.file_name.thumb.url,
        created_at: (record.created_at.to_s(:db) rescue  '')
      }
    end
  end
end
