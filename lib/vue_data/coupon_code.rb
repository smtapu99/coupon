module VueData
  class CouponCode < VueData::Base
    private

    def records
      ::CouponCode.grid_filter(params)
    end

    def data(record)
      {
        id: record.id,
        coupon_id: record.coupon_id,
        code: record.code,
        tracking_user_id: record.tracking_user_id,
        is_imported: record.is_imported,
        end_date: (record.end_date.to_s(:db) rescue  ''),
        used_at: (record.used_at.to_s(:db) rescue  ''),
        created_at: (record.created_at.to_s(:db) rescue  ''),
        updated_at: (record.updated_at.to_s(:db) rescue  '')
      }
    end
  end
end
