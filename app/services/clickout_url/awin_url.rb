class ClickoutUrl::AwinUrl < ClickoutUrl::StandardUrl

  DEEPLINK_PARAM = 'p'
  ALLOWED_MANUAL_CLICKREFS = [
    'clickref3',
    'clickref4',
    'clickref6'
  ]

  ###
  # Takes the URL from the AWIN Affiliate network
  # splits it and adds our custom clickrefs
  # if a deeplink is attached it adds it to the last position
  #
  # @return clickout_url (string)
  ###
  def add_tracking
    # hashify the params
    original_params = @query_params

    # remove the deeplink to be able to add it to the last position
    deeplink = original_params.delete(DEEPLINK_PARAM)

    # merge them with dynamic clickrefs and keep original params if set
    merged = original_params.reverse_merge(clickrefs)

    # add the deeplink if present
    merged = merged.merge({DEEPLINK_PARAM => deeplink}) if deeplink.present?

    # get the base url => everything before the query string
    base_url = Addressable::URI.parse(@uri.to_s.split('?')[0])

    # and set its new query params with merged
    base_url.query_values = merged if merged.present?

    return base_url.to_s
  end

  def clickrefs
    clickrefs = {
      "clickref" => 'pctracking',
      "clickref2" => @coupon.site.host_and_subdir_name,
      "clickref5" => coupon_type_clickref
    }
    # manual clickrefs can come from the controller and contain page specific values
    clickrefs.merge(@manual_clickrefs.select{|k, v| ALLOWED_MANUAL_CLICKREFS.include?(k.to_s)})
  end

  def coupon_type_clickref
    if @coupon.is_exclusive?
      return 'exclusive deal'
    else
      @coupon.coupon_type.downcase
    end
  end
end
