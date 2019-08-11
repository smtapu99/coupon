class TrackingsController < ActionController::Base
  class BaseError < StandardError; end
  class AccessDeniedError < BaseError; end

  rescue_from AccessDeniedError, with: :render_forbidden

  before_action :check_xhr

  def set
    track_click_in = Tracking::Click::In.new(get_site, request, params, cookies).call
    render_json({ tracking_user_id: track_click_in.tracking_user_id }, :created)
  end

  private

  def get_site
    Site.current = Site.multisite_per_request(request) || Site.by_host(request.host).first
    @site = SiteFacade.new(Site.current)
  end

  def check_xhr
    raise AccessDeniedError.new('Forbidden') unless request.xhr?
  end

  def render_json(body, status)
    render json: body, status: status
  end

  def render_error(error_message, status)
    render_json error_message, status
  end

  def render_forbidden(e)
    render_error 'Forbidden ', :forbidden
  end
end
