class CampaignImportWorker < BaseWorker
  @queue = :campaign_import_queue

  def self.perform campaign_import_id
    retries = 2
    begin
      campaign_import  = CampaignImport.find(campaign_import_id)
    rescue Exception => e
      sleep 2
      if (retries -= 1) > 0
        retry
      else
        raise 'Campaign Import ' +campaign_import_id+ ' not found'
      end
    end

    begin
      campaign_import.update_attribute(:status, 'running')
      current_user(campaign_import.user)
      campaign_import.run
    rescue Exception => e
      campaign_import.update_attribute(:status, 'error')
      campaign_import.update_attribute(:error_messages, e.to_s)
    end
  end

  def self.current_user(user)
    User.current = user.class_by_role.find(user.id)
  end
end
