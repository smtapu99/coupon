module VueData
  class TagImport < VueData::Base
    private

    def records
      ::TagImport.grid_filter(params)
    end

    def data(record)
      {
        id: record.id,
        file: record.file.url,
        status: record.status,
        created_at: (record.created_at.to_s(:db) rescue  '')
      }
    end
  end
end
