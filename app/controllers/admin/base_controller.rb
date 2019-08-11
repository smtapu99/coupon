module Admin
  class BaseController < ApplicationController

    protect_from_forgery with: :exception

    layout 'admin'

    before_action :set_title
    before_action :set_i18n_globals
    before_action :set_current_user
    before_action :set_current_site
    before_action :set_current_time_zone
    before_action :check_presence_of_site
    before_action :set_alerts

    rescue_from ActionController::InvalidAuthenticityToken do |exception|
      if admin_user_signed_in?
        redirect_to admin_root_path(only_path: true), alert: exception.message
      else
        redirect_to new_admin_user_session_path(only_path: true), alert: exception.message
      end
    end

    rescue_from CanCan::AccessDenied do |exception|
      if admin_user_signed_in?
        redirect_to admin_root_path(only_path: true), alert: exception.message
      else
        redirect_to new_admin_user_session_path(only_path: true), alert: exception.message
      end
    end

    rescue_from ActionController::RoutingError, with: :access_denied

    def set_title
      content_for(:title, 'Backend: ' + params[:controller].gsub('admin/', '').titleize + ' ' + params[:action].titleize)
    end

    def set_i18n_globals
      I18n.global_scope = :backend
      I18n.locale = 'en-US'
    end

    def default_url_options
      if @current_site.present?
        { protocol: @current_site.protocol }
      else
        {}
      end
    end

    # Set the current user into User.current
    #
    # @return [Object] The current user
    def set_current_user
      if current_admin_user
        @current_admin_user = current_admin_user.to_subclass.find(current_admin_user.id)
        User.current = @current_admin_user
      else
        raise CanCan::AccessDenied
      end
    end

    # Set the current site ID
    #
    # @return [Object] A site
    def set_current_site
      if admin_user_session[:current_site_id].present?
        Site.current = Site.find(admin_user_session[:current_site_id])
      elsif admin_user_session[:current_site_id] == ''
        Site.current = nil
      else
        Site.current = User.current.sites.by_host(request.host).first
      end

      @current_site = Site.current
    end

    # Set the current Time Zone
    def set_current_time_zone
      if Site.current.present?
        Time.zone = (Site.current.time_zone.present?) ? Site.current.time_zone : 'Berlin'
      end
    end

    # Creates a new admin ability
    #
    # @return [Object] AdminAbility
    def current_ability
      current_ability ||= AdminAbility.new(current_admin_user)
    end

    def set_download_complete_cookie
      cookies[:download_complete] = true
    end

    private

    def set_alerts
      @alerts = {}
      return unless Site.current.present?

      base = Site.current.alerts.active
      @alerts[:coupons_expiring] = base.where(alert_type: 'coupons_expiring').count
      @alerts[:uniq_codes_empty] = base.where(alert_type: 'uniq_codes_empty').count
      @alerts[:widget_coupons_expiring_3_days] = base.where(alert_type: 'widget_coupons_expiring_3_days').count
    end

    def access_denied
      flash[:error] = 'You are not authorized to access this page'
      redirect_to admin_root_path
    end

    def allowed_locales
      @allowed_locales ||= User.current.allowed_locales if User.current.present?
    end

    def allowed_site_ids
      @allowed_site_ids ||= User.current.allowed_site_ids if User.current.present?
    end

    def allowed_user_ids
      @allowed_user_ids ||= User.current.allowed_user_ids if User.current.present?
    end

    def allowed_user_roles
      @allowed_user_roles ||= User.current.allowed_user_roles if User.current.present?
    end

    def check_presence_of_site
      if !Site.current.present? && controller_requires_site?
        flash[:error] = 'Access Denied! Please select a site first.'
        redirect_to admin_root_path
      end
    end

    def controller_requires_site?
      [
        'admin/campaigns',
        'admin/categories',
        'admin/coupons',
        'admin/media',
        'admin/snippets',
        'admin/caches',
        'admin/redirect_rules',
        'admin/settings',
        'admin/shops',
        'admin/static_pages',
        'admin/tags',
        'admin/templates',
        'admin/translations',
        'admin/widgets'
      ].include? params[:controller]
    end

    def validate_super_admin
      raise CanCan::AccessDenied, 'Only Super Admin is allowed to perform this action' unless User.current.is_super_admin?
    end
  end
end
