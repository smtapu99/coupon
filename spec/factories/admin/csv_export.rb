module Admin
  FactoryGirl.define do

    factory :csv_export do
      association :user, factory: [:admin]
    end

  end
end
