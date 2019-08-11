class Admin::Users::TwoFactorsController < Admin::BaseController
  before_action :authenticate_admin_user!, :set_mfa_user

  def create
    if @mfa_user.otp_module_disabled?
      @mfa_user.assign_attributes(two_factor_params)
      if !!@mfa_user.authenticate_otp(authenticate_otp_token, drift: 60)
        @mfa_user.save!
        flash[:notice] = I18n.t('devise.sessions.two_factor_auth.enabled')
      else
        flash[:alert] = I18n.t('devise.sessions.two_factor_auth.incorrect_code')
      end
    else
      flash[:alert] = I18n.t('devise.sessions.two_factor_auth.already_enabled')
    end
    redirect_back fallback_location: edit_admin_user_path(@mfa_user)
  end

  def destroy
    if !!@mfa_user.authenticate_otp(authenticate_otp_token, drift: 60)
      @mfa_user.otp_module_disabled!
      flash[:notice] = I18n.t('devise.sessions.two_factor_auth.disabled')
    else
      flash[:alert] = I18n.t('devise.sessions.two_factor_auth.incorrect_code')
    end
    redirect_back fallback_location: edit_admin_user_path(@mfa_user)
  end

  private

  def authenticate_otp_token
    params.require(:user).require(:token_otp)
  end

  def set_mfa_user
    @mfa_user = User.current
  end

  def two_factor_params
    params.require(:user).permit(:otp_secret_key).merge(otp_module: User.otp_modules[:enabled])
  end
end
