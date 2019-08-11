class ApplicationController < ActionController::Base

  before_action :store_user_location!, if: :storable_location?
  before_action :set_default_i18n_globals

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def after_sign_in_path_for(user)
    return destroy_admin_user_session_path inactive: true unless user.allowed_to_sign_in?

    stored_location_for(user) || admin_root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_admin_user_session_path
  end

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  private

  # Set the Locale
  def set_default_i18n_globals
    I18n.global_scope = :backend
    I18n.locale = 'en-US'
  end

  # Its important that the location is NOT stored if:
  # - The request method is not GET (non idempotent)
  # - The request is handled by a Devise controller such as Devise::SessionsController as that could cause an
  #    infinite redirect loop.
  # - The request is an Ajax request as this can lead to very unexpected behaviour.
  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    # :user is the scope we are authenticating
    store_location_for(:user, request.fullpath)
  end
end
