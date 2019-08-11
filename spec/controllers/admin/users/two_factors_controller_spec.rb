describe Admin::Users::TwoFactorsController do

  login_admin

  let(:user) { User.last }
  let(:otp_secret_key) { User.otp_random_secret }
  let(:token_otp) { user.assign_attributes(otp_secret_key: otp_secret_key); user.otp_code }

  context '#create' do
    context 'success' do
      subject! { post :create, params: {user: {otp_secret_key: otp_secret_key, token_otp: token_otp}} }

      it 'should change otp_module status to enabled' do
        expect(user.reload.otp_module_enabled?).to be true
      end

      it 'should update otp_secret_key' do
        expect(user.reload.otp_secret_key).not_to be_empty
      end

      context '#set_mfa_user' do
        it 'should return current user' do
          expect(assigns(:mfa_user).id).to eq(user.id)
        end
      end
    end

    context 'invalid token_otp' do
      it '2fa should be disable' do
        post :create, params: {user: {otp_secret_key: otp_secret_key, token_otp: 'invalid'}}

        expect(user.reload.otp_module_enabled?).to be false
        expect(user.reload.otp_secret_key).not_to be_empty
      end
    end

    context '2fa already enabled' do
      let(:otp_secret_key_2) { User.otp_random_secret }
      before do
        user.update(otp_secret_key: otp_secret_key_2, otp_module: User.otp_modules[:enabled])
      end

      it 'otp_secret_key should not be updated' do
        post :create, params: {user: {otp_secret_key: otp_secret_key, token_otp: 'invalid'}}

        expect(user.reload.otp_module_enabled?).to be true
        expect(user.reload.otp_secret_key).to eq(otp_secret_key_2)
      end
    end
  end

  context '#destroy' do
    before do
      user.update(otp_secret_key: otp_secret_key, otp_module: User.otp_modules[:enabled])
    end

    context 'success' do
      it '2fa should be disabled' do
        delete :destroy, params: {user: {token_otp: token_otp}}

        expect(user.reload.otp_module_disabled?).to be true
      end
    end

    context 'invalid token_otp' do
      it '2fa should be enabled' do
        delete :destroy, params: {user: {token_otp: 'invalid'}}

        expect(user.reload.otp_module_enabled?).to be true
        expect(user.reload.otp_secret_key).not_to be_empty
      end
    end
  end
end
