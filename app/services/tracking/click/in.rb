class Tracking::Click::In < Tracking::Click::Base

  attr_reader :site, :request, :params, :cookies

  def initialize(site, request, params, cookies)
    @site, @request, @params, @cookies = site, request, params, cookies
  end

  private

  def click_params
    {
      site_id: site.id,
      tracking_user_id: current_tracking_user.id,
      landing_page: request.referer,
      click_type: 'click_in',
      utm_source: extract_query_param(:utm_source),
      utm_campaign: extract_query_param(:utm_campaign),
      utm_medium: extract_query_param(:utm_medium),
      utm_term: extract_query_param(:utm_term),
      channel: extract_channel(origin_referrer, params)
    }.merge(campaign_tracking_data_params)
  end

  def origin_referrer
    if params[:query_string_params].present? && params[:query_string_params][:referrer].present?
      params[:query_string_params][:referrer]
    end
  end

  def extract_query_param(tag_name)
    if params[:query_string_params].present? && params[:query_string_params][tag_name].present?
      URI.unescape(params[:query_string_params][tag_name])
    end
  end

  def campaign_tracking_data_params
    return {} unless params.dig(:query_string_params, :gclid)
    {
      campaign_tracking_data_attributes: {
        data: params[:query_string_params]
      }
    }
  end

  #adwords = if the referer URL contains the gclid param on it
  #facebook = facebook.com domain
  #newsletter = list-manage.com domain
  #organic = If domain contains the words "google, bing or yahoo"
  #other = any domain
  #direct = no referrer
  def extract_channel(url, params)
    return 'adwords' if extract_query_param(:gclid).present?
    return 'direct'  if url.blank? || url == 'unknown'

    begin
      parsed = URI.parse(URI.encode(url))
      url = "http://#{url}" if parsed.scheme.nil?
      host = parsed.host.present? ? parsed.host.downcase : ''
      query = parsed.query
      query.present? ? CGI::parse(parsed.query) : {}
    rescue URI::InvalidURIError => e
      return 'invalid'
    end

    if host.start_with?('facebook.com')
      'facebook'
    elsif host.include?('list-manage.com')
      'newsletter'
    elsif ['google', 'yahoo', 'bing'].any? {|word| url.include?(word)}
      'organic'
    else
      'other'
    end
  end
end
