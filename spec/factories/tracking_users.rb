FactoryGirl.define do

  factory :tracking_user do
    uniqid SecureRandom.urlsafe_base64(23)

    association :site, factory: :site

    trait :with_coupon do
      association :coupon, factory: :coupon
    end

    trait :with_coupon_code do
      association :coupon_code, factory: :coupon_code
    end

  end

end
