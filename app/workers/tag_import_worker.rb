class TagImportWorker < BaseWorker
  @queue = :tag_import_queue

  def self.perform tag_import_id
    retries = 2
    begin
      tag_import  = TagImport.find(tag_import_id)
    rescue Exception => e
      sleep 2
      if (retries -= 1) > 0
        retry
      else
        raise 'Tag Import ' + tag_import_id + ' not found'
      end
    end

    begin
      tag_import.update_attribute(:status, 'running')
      Site.current = tag_import.site
      tag_import.run
    rescue Exception => e
      tag_import.update_attribute(:status, 'error')
      tag_import.update_attribute(:error_messages, e.to_s)
    end
  end
end
