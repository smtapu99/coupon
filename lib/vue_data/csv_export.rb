module VueData
  class CsvExport < VueData::Base
    private

    def filters
      ::CsvExport.grid_filter_dropdowns
    end

    def records
      ::CsvExport.grid_filter(params)
    end

    def records_paginated
      base = records.page(page).per(per_page)

      case order.to_sym
      when :user
        base.includes(:user).order("users.first_name #{direction}")
      else
        base.order(order => direction)
      end
    end

    def data(record)
      {
        id: record.id,
        export_type: record.export_type,
        status: record.status,
        file: record.file.url,
        user: record.user.full_name,
        params: record.sanitized_params_string,
        created_at: (record.created_at.to_s(:db) rescue  ''),
        last_executed: (record.last_executed.to_s(:db) rescue  '')
      }
    end
  end
end
