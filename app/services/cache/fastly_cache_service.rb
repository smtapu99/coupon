class Cache::FastlyCacheService

  DEFAULT_FASTLY_PURGE_URI = 'http://a.prod.fastly.net'.freeze
  WLS_FASTLY_PURGE_URI = 'https://app-production-wls.global.ssl.fastly.net/'.freeze

  def initialize(site)
    @site = site
    @fastly_uri = fastly_uri
    @cache_purge_host = cache_purge_host
    @auth_key = @site.setting.get('caching.fastly_auth_key')
    @service_id = @site.setting.get('caching.fastly_service_id')

    establish_connection
  end


  # We choose to use Net::HTTP implementation rather then @fastly.purge because our
  # sites might be behind cloudflare or other services - so we need to send the PURGE
  # request to the @fastly_uri with 'Host'-Header set to e.g. publisher.com
  def purge(urls)
    begin
      [*urls].each do |url|

        if Rails.env.development? && @site.id == 1
          url.gsub!('localhost', 'cupon.es')
        end

        purgeable_uri = URI(url)
        net = Net::HTTP.start(@fastly_uri.host, @fastly_uri.port, use_ssl: use_ssl?) do |http|
          req = Net::HTTP::Purge.new purgeable_uri.path.present? ? purgeable_uri.path : '/'
          req['Fastly-Key'] = @auth_key
          req['Host'] = @cache_purge_host

          http.request req
        end

        raise 'Invalid Request' if net.code != '200' && Rails.env.production?
      end
    rescue StandardError => e
      raise e if Rails.env.development?
      return false
    end

    true
  end

  def purge_key(key)
    begin
      net = @service.purge_by_key(key)

      raise 'Invalid Request' unless net['status'] == 'ok'
    rescue Exception => e
      raise e if Rails.env.development?
      return false
    end

    true
  end

  def purge_all
    begin
      net = @service.purge_all

      raise 'Invalid Request' unless net['status'] == 'ok'
    rescue Exception => e
      raise e if Rails.env.development?
      return false
    end

    true
  end

  private

  def use_ssl?
    @fastly_uri.scheme == 'https'
  end

  def fastly_uri
    return URI(WLS_FASTLY_PURGE_URI) if @site.is_wls?
    URI(DEFAULT_FASTLY_PURGE_URI)
  end

  def cache_purge_host
    return 'cupon.es' if Rails.env.development? && @site.id == 1
    @site.setting.get('caching.fastly_cache_purge_host', default: @site.hostname)
  end

  def establish_connection
    @fastly  = Fastly.new(api_key: @auth_key)
    @service = Fastly::Service.new({ id: @service_id }, @fastly)
  end
end
