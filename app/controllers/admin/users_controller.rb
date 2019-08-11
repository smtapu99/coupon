require 'vue_data/user'

module Admin
  class UsersController < BaseController
    before_action :authenticate_admin_user!
    load_and_authorize_resource except: [:create]

    before_action :set_user, only: [:edit, :update]

    # GET /admin/users
    def index
      respond_to do |format|
        format.json { render json: VueData::User.render_json(nil, params), status: :ok }
        format.html
      end
    end

    # GET /admin/users/new
    def new
      type = params[:type] || 'partner'
      klass = type == 'admin' ? 'super_user' : type

      raise CanCan::AccessDenied unless User.current.allowed_to_manage klass

      @user = klass.classify.constantize.new
      @user.role = type
    end

    # GET /admin/users/1/edit
    def edit
    end

    # POST /admin/users
    def create
      raise CanCan::AccessDenied unless User.current.allowed_to_manage params_key.to_s

      @user = user_params[:role].to_s.classify.constantize.new(user_params)

      @user.current_sign_in_ip = request.remote_ip
      @user.last_sign_in_ip = request.remote_ip

      respond_to do |format|
        if @user.save
          format.html { redirect_to admin_users_url, notice: 'User was successfully created.' }
        else
          format.html { render action: 'new', params: {type: params_key.to_s} }
        end
      end
    end

    def update
      successfully_updated = if needs_password?
        if User.current.is_admin?
          params[params_key].delete(:current_password)
          @user.update_attributes(user_params)
        else
          @user.update_with_password(user_params)
        end
      else
        params[params_key].delete(:current_password)
        @user.update_without_password(user_params)
      end

      respond_to do |format|
        if successfully_updated
          @user.update_attributes(can_metas: true, can_shops: true, can_coupons: true) unless @user.is_freelancer?
          sign_in(@user, bypass: true) if @user.id == User.current.id
          format.html { redirect_to admin_users_url, notice: 'Login was successfully updated.' }
        else
          format.html { render action: 'edit' }
        end
      end
    end

    def set_current_site_id
      if User.current.sites.map(&:id).include?(params[:site_id].to_i)
        admin_user_session[:current_site_id] = params[:site_id]
      end
      redirect_to request.referer
    end

    def unset_current_site_id
      # this is to make a difference between nil and empty
      # when nil? then the site which matches the current host gets selected
      admin_user_session[:current_site_id] = ''
      redirect_to request.referer
    end

    private

    # make sure you delete the right records also when role gets changed
    def sanitize_user_params
      if User::SITE_BASED_ROLES.include?(params[params_key][:role].to_sym)
        params[params_key].delete(:country_ids)
      elsif User::COUNTRY_BASED_ROLES.include?(params[params_key][:role].to_sym)
        params[params_key].delete(:site_ids)
      elsif User::ADMIN_ROLES.include?(params[params_key][:role].to_sym)
        params[params_key].delete(:site_ids)
      end
    end

    def user_class_name
      if User.current.is_admin? && user_params[:role].present? && user_params[:role] != @user.role
        if user_params[:role] == 'admin'
          SuperUser
        else
          user_params[:role].to_s.classify.constantize
        end
      else
        params_key.to_s.classify.constantize
      end
    end

    # check if we need password to update user data
    # ie if password or email was changed
    # extend this as needed
    def needs_password?
      params[params_key][:password].present?
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_user
      user = User.where(id: params[:id]).where(id: allowed_user_ids).first || not_found
      # this is to find the user with the right role after a role change
      if params[:action] == 'update' && User.current.allowed_to_manage(user.role) && user.role != params[params_key][:role].to_s
        user.reset_role_relations!(params[params_key][:role])
      end

      # user needs to be an instance of the correct user class ... f.e. Partner
      user = User.where(id: params[:id]).where(id: allowed_user_ids).first || not_found
      @user = user.to_subclass.find(params[:id])
    end

    def params_key
      @params_key ||= params.keys.select {|k| %w(super_user country_editor country_manager partner regional_manager freelancer).include? k }.first.to_sym
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      sanitize_user_params

      params.require(params_key).permit(
        :status,
        :first_name,
        :last_name,
        :email,
        :password,
        :role,
        :current_password,
        :password_confirmation,
        :can_metas,
        :can_shops,
        :can_coupons,
        :can_widgets,
        :can_qa,
        country_ids: [],
        site_ids: []
      )
    end
  end
end
