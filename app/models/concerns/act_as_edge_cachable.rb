module ActAsEdgeCachable
  extend ActiveSupport::Concern

  included do
    include OptionHelper

    def purge_resource_key
      purge_key resource_key
    end

    def purge_table_key
      purge_key table_key
    end

    def resource_key
      "#{table_key}/#{id}"
    end

    def table_key
      self.class.table_name
    end

    def fastly_config_valid?
      setting = Site.find(site_id).setting
      [Rails.env.production?,
       setting.get('caching.proxy_server_type') == 'fastly',
       setting.get('caching.fastly_auth_key'),
       setting.get('caching.fastly_service_id'),
       setting.get('caching.use_surrogate_keys')].all?
    rescue StandardError
      logger.error 'Error while validating fastly config'
      return false
    end

    def purge_key(key)
      begin
        CacheService.new(site).purge_key(key)
      rescue
        log_purging_error key
      end
    end

    private

    def log_purging_error(key)
      logger.error "Error purging fastly key. #{@fastly_service_id} - #{key}"
    end
  end
end
