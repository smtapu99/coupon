class Tracking::Click::Base
  include TrackingHelper

  def call
    TrackingClick.create(click_params)
  end

  private

  def current_tracking_user
    @current_tracking_user = Tracking::User::Fetch.new(site, request, params, cookies).call
  end

  def session
    request.session
  end
end
