class Auth < Grape::API
  # /api/auth
  resource :auth do

    desc "Creates and returns access_token if valid login"
    params do
      requires :login, :type => String, :desc => "Username or email address"
      requires :password, :type => String, :desc => "Password"
    end
    post :login do
      user = User.find_by_email(params[:login].downcase)

      if user && user.valid_password?(params[:password])
        key = ApiKey.create(user_id: user.id)
        { token: key.access_token }.to_json
      else
        error!('Unauthorized.', 401)
      end
    end
  end
end
