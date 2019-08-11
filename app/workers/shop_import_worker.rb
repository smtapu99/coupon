class ShopImportWorker < BaseWorker
  @queue = :shop_import_queue

  def self.perform shop_import_id
    retries = 2
    begin
      shop_import  = ShopImport.find(shop_import_id)
    rescue Exception => e
      sleep 2
      if (retries -= 1) > 0
        retry
      else
        raise 'Shop Import ' + shop_import_id + ' not found'
      end
    end

    begin
      shop_import.update_attribute(:status, 'running')
      current_user(shop_import.user)
      shop_import.run
    rescue Exception => e
      shop_import.update_attribute(:status, 'error')
      shop_import.update_attribute(:error_messages, e.to_s)
    end
  end

  def self.current_user(user)
    User.current = user.class_by_role.find(user.id)
  end

end
