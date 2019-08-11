require 'capybara/rspec'

describe "2fa authentication", type: :feature do

  let!(:user) { create(:admin) }

  context 'POST pre_sign_in' do
    subject do
      visit new_admin_user_session_path
      fill_in 'E-mail', with: user.email
      click_button 'Next'
    end

    context 'when 2fa is enabled ' do
      before do
        user.update(otp_secret_key:  User.otp_random_secret, otp_module: User.otp_modules[:enabled])
      end

      it 'should render step 2 form with password and otp_code fields' do
        subject
        expect(page).to have_selector('#step-2')
        expect(page).to have_selector('#step-2 #user_sign_in_password')
        expect(page).to have_selector('#step-2 #user_sign_in_otp_token')
      end
    end

    context 'when 2fa is disabled ' do
      it 'should render only password field' do
        subject
        expect(page).to have_selector('#step-2')
        expect(page).to have_selector('#step-2 #user_sign_in_password')
        expect(page).not_to have_selector('#step-2 #user_sign_in_otp_token')
      end
    end

    context 'when account not found' do
      it 'should render only password field' do
        subject
        expect(page).to have_selector('#step-2')
        expect(page).to have_selector('#step-2 #user_sign_in_password')
        expect(page).not_to have_selector('#step-2 #user_sign_in_otp_token')
      end
    end
  end
end
