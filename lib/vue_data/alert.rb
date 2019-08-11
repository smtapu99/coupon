module VueData
  class Alert < VueData::Base
    include Rails.application.routes.url_helpers

    private

    def records
      ::Alert.grid_filter(params)
    end

    def records_paginated
      base = records.page(page).per(per_page)

      case order.to_sym
      when :model
        base.order(alertable_type: direction)
      when :date
        base.order(updated_at: direction)
      when :model_id
        base.order(alertable_id: direction)
      when :site
        base.includes(:site).order("sites.hostname #{direction}")
      else
        base.order(order => direction)
      end
    end

    def data(record)
      {
        id: record.id,
        is_critical: record.is_critical,
        edit_path: edit_admin_alert_path(record),
        status: record.status,
        alert_type: record.alert_type,
        type: record.alert_type,
        model: record.alertable_type,
        model_id: record.alertable_id,
        message: record.message,
        date: (record.updated_at.to_s(:db) rescue nil)
      }
    end
  end
end
