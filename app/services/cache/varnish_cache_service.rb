class Cache::VarnishCacheService

  def initialize site
    @site = site
  end

  def purge urls
    return false
    # [*urls].each do |url|
    #   uri = URI(url)
    #   Net::HTTP.start(uri.host,uri.port) do |http|
    #     http.request Net::HTTP::Purge.new uri.request_uri
    #     http.request Net::HTTP::Ban.new uri.request_uri
    #   end
    # end
  end

  def purge_key
    return false
  end

  def purge_all
    return false
  end
end
