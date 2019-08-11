module Admin
  FactoryGirl.define do
    factory :banner do
      association :site, factory: :site
      start_date Time.zone.now.to_date
      end_date (Time.zone.now + 1.day).to_date
    end
  end
end
