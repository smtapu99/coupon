module Admin
  FactoryGirl.define do
    factory :shop_import do
      association :user, factory: :user
    end
  end
end
