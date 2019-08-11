FactoryGirl.define do
  sequence(:email) do |value|
    "mail#{value}@user.com"
  end

  factory :user do
    email {FactoryGirl.generate(:email)}
    password 'password'
    password_confirmation 'password'
    role 'guest'
    status 'active'

    factory :admin, class: SuperUser do
      role 'admin'
    end

    factory :super_admin, class: SuperUser do
      role 'admin'
    end

    factory :regional_manager, class: RegionalManager do
      role 'regional_manager'
    end

    factory :country_manager, class: CountryManager do
      role 'country_manager'
    end

    factory :country_editor, class: CountryEditor do
      role 'country_editor'
    end

    factory :freelancer, class: Freelancer do
      role 'freelancer'

      factory :freelancer_no_access do
        can_shops false
        can_coupons false
        can_metas false
      end
    end

    factory :partner, class: Partner do
      role 'partner'
    end

    factory :guest do
      role 'guest'
    end
  end
end
