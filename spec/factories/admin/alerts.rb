# Read about factories at https://github.com/thoughtbot/factory_girl
module Admin
  FactoryGirl.define do
    factory :alert do
      association :site, factory: :site
      association :alertable, factory: :coupon
      alert_type :uniq_codes_empty
    end
  end
end
