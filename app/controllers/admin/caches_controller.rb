module Admin
  class CachesController < BaseController
    include Admin::CacheHelper

    before_action :authenticate_admin_user!

    def index
      @proxy_server_type = Setting.get('caching.proxy_server_type')
      @fastly_auth_key = Setting.get('caching.fastly_auth_key')
    end

    def purge_url
      notice = 'An error has occurred while trying to purge the URL. Make sure you dont purge a url outside of the current site e.g. cupon.es; Otherwise contact your IT.'

      success = if Setting.get('caching.proxy_server_type') == 'fastly' && params[:purge_all].present?
        raise CanCan::AccessDenied unless User.current.is_super_admin?

        if CacheService.new(Site.current).purge_key(Site.current.surrogate_key)
          notice = "Site '#{Site.current.name}' was successfully purged with key '#{Site.current.surrogate_key}'"
        end
      elsif CacheService.new(Site.current).purge(params[:url])
        notice = "URL has been successfully purged, it may take up to 30 seconds to appear."
      end

      if success
        redirect_to admin_caches_path, notice: notice
      else
        redirect_to admin_caches_path, alert: notice
      end
    end
  end
end
