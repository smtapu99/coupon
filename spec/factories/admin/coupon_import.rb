module Admin
  FactoryGirl.define do
    factory :coupon_import do
      association :user, factory: :user
    end
  end
end
