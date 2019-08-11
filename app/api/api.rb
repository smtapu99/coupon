class Api < Grape::API

  before do
    header "X-Robots-Tag", "noindex"
  end

  helpers do

    def bearer_token
      pattern = /^Bearer /
      header  = request.headers['Authorization']
      header.gsub(pattern, '') if header && header.match(pattern)
    end

    def permitted_params
      declared(params)
    end

    def authenticate!
      error!('Unauthorized. Invalid or expired token.', 401) unless authenticated?
    end

    def authenticated?
      key = ApiKey.where(access_token: bearer_token).first
      return false if !key.present? || key.expired?

      if key.user_id.present?
        @current_user = User.find(key.user_id) and @current_user.present?
      elsif key.site_id.present?
        @current_site = Site.find_by(id: key.site_id) and @current_site.present?
      end
    end

    def set_surrogate_key_header(*keys)
      header 'Surrogate-Key',[header['Surrogate-Key'], *keys].reject(&:blank?).join(' ')
    end

    def set_surrogate_control_header(time=3600)
      header "Surrogate-Control", "max-age=#{time}"
    end
  end

  mount ::Api::Auth
  mount ::Versions::V1
end
