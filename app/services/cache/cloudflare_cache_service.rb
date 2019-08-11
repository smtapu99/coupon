class Cache::CloudflareCacheService

  def initialize site
    @site       = site
    @config     = Rails.application.config.custom_services
    @connection = establish_connection
  end

  def purge urls
    begin
      [*urls].each do |url|
        @connection.zone_file_purge(@site.hostname, url)
      end
    rescue CloudFlare::RequestError => e
      return false
    end

    true
  end

  def purge_key
    return false
  end

  def purge_all
    begin
      @connection.delete("zones/#{@zoneid}/purge_cache", purge_everything: true)
    rescue CloudFlare::RequestError => e
      return Rails.env.development? ? raise(e) : false
    end

    true
  end

private

  def establish_connection
    CloudFlare::connection(@config['cloudflare_secret'], @config['cloudflare_user'])
  end

end
