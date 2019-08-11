class ClickoutUrl::StandardUrl
  def initialize coupon, manual_clickrefs={}
    @coupon = coupon
    @uri = parse_uri(@coupon.url)
    @query_params = parse_query(@uri.query)
    @manual_clickrefs = manual_clickrefs
  end

  # Standard track
  def add_tracking
    return @uri.to_s
  end

  private

  def parse_query(query)
    parts = Rack::Utils.parse_nested_query(sanitize_query_string(query))
    sanitize_query_parts(parts)
  end

  def sanitize_query_parts(parts)
    return parts unless parts.is_a?(Hash)

    parts.each_value do |value|
      value.gsub!('***', ';')
    end
  end

  # found a problem that ; in deeplink is breaking the query split
  def sanitize_query_string(query)
    query.gsub(';', '***') if query.present?
  end

  def parse_uri uri
    URI.parse(uri)
  end
end
