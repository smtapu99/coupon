module Admin
  FactoryGirl.define do

    factory :coupon_code do
      association :site, factory: :site
      sequence(:code) { |n| "CC#{n}" }

      trait :with_coupon do
        association :coupon, factory: :coupon
      end

      trait :imported do
        is_imported true
      end

      trait :with_tracking_user do
        association :tracking_user, factory: :tracking_user
      end

    end

  end
end
