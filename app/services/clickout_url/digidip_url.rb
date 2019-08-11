class ClickoutUrl::DigidipUrl < ClickoutUrl::StandardUrl

  ###
  # Takes the URL from the Digidip Affiliate network
  # splits it and adds our custom clickrefs
  #
  # @return clickout_url (string)
  ###
  def add_tracking
    # hashify the params
    original_params = @query_params

    # merge them with dynamic clickrefs and keep original params if set
    merged = original_params.reverse_merge(clickrefs)

    # get the base url => everything before the query string
    base_url = Addressable::URI.parse(@uri.to_s.split('?')[0])

    # and set its new query params with merged
    base_url.query_values = merged if merged.present?

    return base_url.to_s
  end

  def clickrefs
    {
      "ref" => 'pctracking',
      "ppref" => 'https://' + @coupon.site.host_and_subdir_name,
    }
  end
end
