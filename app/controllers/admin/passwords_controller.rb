module Admin
  class PasswordsController < Devise::PasswordsController
    layout 'login'
  end
end
