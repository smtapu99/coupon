class CouponImportWorker < BaseWorker
  @queue = :coupon_import_queue

  def self.perform coupon_import_id
    retries = 2
    begin
      coupon_import = CouponImport.find(coupon_import_id)
    rescue Exception => e
      sleep 2
      if (retries -= 1) > 0
        retry
      else
        raise 'Coupon Import ' +coupon_import_id+ ' not found'
      end
    end

    begin
      coupon_import.update_attribute(:status, 'running')
      current_user(coupon_import.user)
      coupon_import.run
    rescue Exception => e
      coupon_import.update_attribute(:status, 'error')
      coupon_import.update_attribute(:error_messages, e.to_s)
    end
  end

  def self.current_user(user)
    User.current = user.class_by_role.find(user.id)
  end
end
