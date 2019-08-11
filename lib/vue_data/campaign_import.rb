module VueData
  class CampaignImport < VueData::Base
    private

    def records
      ::CampaignImport.grid_filter(params)
    end

    def filters
      ::CampaignImport.grid_filter_dropdowns
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
        user: record.user.full_name,
        file: record.file.url,
        status: record.status,
        created_at: (record.created_at.to_s(:db) rescue  '')
      }
    end
  end
end
