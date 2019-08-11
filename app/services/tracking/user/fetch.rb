class Tracking::User::Fetch
  include ApplicationHelper

  attr_reader :site, :request, :params, :cookies

  def initialize(site, request, params, cookies)
    @site, @request, @params, @cookies = site, request, params, cookies
  end

  def call
    tracking_user = tracking_user_by_sub_id || TrackingUser.create(tracking_user_params)
    set_sub_id_tracking(tracking_user)

    tracking_user
  rescue Exception => e
    Rails.logger.fatal 'ERROR IN TRACKING: ' + e.inspect
    Rails.logger.fatal 'TRACKING DATA HASH: ' + extract_data.inspect
    nil
  end

  private

  def session
    request.session
  end

  def set_sub_id_tracking(tracking_user)
    session[:subIdTracking] = tracking_user.uniqid
    cookies.permanent[:subIdTracking] = {
      value: tracking_user.uniqid,
      domain: :all,
      path: Setting::get('routes.application_root_dir', default: '/'),
      httponly: true
    }
  end

  def tracking_user_params
    {
      site_id: site.id,
      data: (extract_data rescue nil),
      referrer: ((!extract_data.is_a?(Hash) || extract_data['referrer'] === 'unknown') ? '' : extract_data['referrer']),
      gclid: (extract_data['gclid'] rescue nil),
      uniqid: SecureRandom.urlsafe_base64(23)
    }.merge(geo_ip_params)
  end

  def geo_ip_params
    {
      country: request.headers['X-Geo-Country-Name'],
      city: request.headers['X-Geo-City'],
      postal_code: request.headers['X-Geo-Postcode']
    }
  end

  def tracking_user_by_sub_id
    subid = cookies[:subIdTracking] || session[:subIdTracking]
    TrackingUser.find_by(uniqid: subid)
  end

  def extract_data
    @extract_data ||= params[:query_string_params].present? ? params[:query_string_params] : extract_data_from_url
  end

  def extract_data_from_url
    parsed_url = URI.parse(URI.encode(original_url_with_custom_protocol))
    params = if parsed_url.query.present?
               (parsed_params = CGI.parse(parsed_url.query)).present? ? parsed_params : {}
             else
               {}
             end
    params.merge({ referrer: request.referer })
  end
end
