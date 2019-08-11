require 'net/http'

module Net
  class HTTP::Purge < HTTPRequest
    METHOD = 'PURGE'
    REQUEST_HAS_BODY = false
    RESPONSE_HAS_BODY = true
  end

  class HTTP::Ban < HTTPRequest
    METHOD = 'BAN'
    REQUEST_HAS_BODY = false
    RESPONSE_HAS_BODY = true
  end
end

module Admin::CacheHelper
  include OptionHelper

  def purge_table_key(object)
    object.purge_table_key
  end

  def purge_resource_key(object)
    object.purge_resource_key
  end

  def purge(urls)
    begin
      @settings = Site.current.setting
      proxy_server_type = Setting::get('caching.proxy_server_type')

      case proxy_server_type
      when 'cloudflare'
        zoneid = Setting::get('caching.cloudflare_zone_id', default: nil)
        cloudflare_purge(urls, zoneid)
      when 'varnish'
        varnish_purge(urls)
      when 'fastly'
        [*urls].each do |url|
          # tries to figure out if people want to purge the homepage # strips anything like http://www.cupom.com/my-url/ to cupom.com/my-url
          if target_site = Site.find_by(hostname: url.sub(/^https?\:\/\/(www.)?/,'').sub(/\/+$/,''))
            @settings.purge_key "home_#{target_site.id}"
          else
            auth_key = Setting::get('caching.fastly_auth_key')
            fastly_purge(url, auth_key)
          end
        end
      end
      return true
    rescue Exception => e
      return false
    end
  end

  def varnish_purge(url)
    uri = URI(url)
    Net::HTTP.start(uri.host,uri.port) do |http|
      http.request Net::HTTP::Purge.new uri.request_uri
      http.request Net::HTTP::Ban.new uri.request_uri
    end
  end

  def fastly_purge(url, auth_key)
    uri = URI(url)
    Net::HTTP.start(uri.host,uri.port) do |http|
      req = Net::HTTP::Purge.new uri.request_uri
      req['Fastly-Key'] = auth_key
      http.request req
    end
  end

  def cloudflare_purge urls, zoneid
    connection = cloudflare_connection
    hostname   = Rails.env.development? ? 'cupon.es' : Site.current.hostname # as development runs on localhost not cupon.es
    zoneid     = zoneid.present? ? zoneid : cloudflare_get_zone_id(connection, hostname)

    if zoneid.present?
      begin
        connection.delete("zones/#{zoneid}/purge_cache", files: [*urls])
      rescue Rubyflare::ConnectionError => e
        raise e
      end
    else
      raise 'Cloudflare Error: Invalid Zone Id'
    end

    return true
  end

  def cloudflare_get_zone_id connection, hostname
    if res = connection.get('zones', name: hostname).result and !res.nil?
      res[:id]
    end
  end

  def cloudflare_connection
    config = Rails.application.config.custom_services
    Rubyflare.connect_with(config['cloudflare_user'], config['cloudflare_secret'])
  end

end

