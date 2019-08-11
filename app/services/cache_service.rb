class CacheServiceException < Exception
end

class CacheService
  def initialize(site)
    proxy_type = site.setting.get('caching.proxy_server_type', default: nil)
    @adaptor   = adaptor_class(proxy_type, site)
  end

  def purge(urls)
    @adaptor.purge(urls)
  rescue CacheServiceException
    return false
  end

  def purge_all
    @adaptor.purge_all
  rescue CacheServiceException
    return false
  end

  def purge_key(key)
    @adaptor.purge_key(key)
  rescue CacheServiceException
    return false
  end

  private

  def adaptor_class(proxy_type, site)
    case proxy_type
    when 'fastly'
      Cache::FastlyCacheService.new(site)
    when 'cloudflare'
      Cache::CloudflareCacheService.new(site)
    else
      Cache::VarnishCacheService.new(site)
    end
  end
end
