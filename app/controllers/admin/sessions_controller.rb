module Admin
  class SessionsController < Devise::SessionsController
    helper_method :otp_authenticated?

    layout 'login'

    def pre_sign_in
      self.resource = resource_class.new(sign_in_params)
      clean_up_passwords(resource)
      @user = User.find_by pre_sign_in_params
      render 'sign_in_step_2'
    end

    def create
      self.resource = warden.authenticate!(auth_options)
      if resource.otp_module_disabled? || authenticate_otp
        super
      else
        sign_out
        flash[:alert] = I18n.t('devise.sessions.two_factor_auth.incorrect_code')
        redirect_back fallback_location: new_admin_user_session_path
      end
    end

    # DELETE /resource/sign_out
    def destroy
      signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
      if params[:inactive]
        # this is because flash is not persistent after application_controller/after_sign_in_path_for
        flash[:error] = 'Your login credentials are currently inactive or you have no resources assigned.'
      else
        set_flash_message :notice, :signed_out if signed_out && is_flashing_format?
      end
      yield if block_given?
      respond_to_on_destroy
    end

  private
    def respond_to_on_destroy
      # We actually need to hardcode this as Rails default responder doesn't
      # support returning empty response on GET request
      respond_to do |format|
        format.all { head :no_content }
        format.any(*navigational_formats) { redirect_to after_sign_out_path_for(resource_name) }
      end
    end

    def authenticate_otp_token
      params.require(:admin_user).require(:token_otp)
    end

    def pre_sign_in_params
      params.require(:admin_user).permit(:email)
    end

    def last_authenticated_otp
      cookies[:last_authenticated_otp]
    end

    def authenticate_otp
      return true if otp_authenticated?
      if resource.otp_module_enabled? && !!resource.authenticate_otp(authenticate_otp_token, drift: 60)
        cookies[:last_authenticated_otp] = Time.now
        true
      else
        false
      end
    end

    def otp_authenticated?
      last_authenticated_otp.present? && (last_authenticated_otp.to_time + 24.hour > Time.now)
    end
  end
end
