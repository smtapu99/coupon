# Read about factories at https://github.com/thoughtbot/factory_girl

module Admin
  FactoryGirl.define do
    sequence(:global_name) do |value|
      "Country #{value}"
    end

    factory :global do
      name { FactoryGirl.generate(:global_name) }
      model_type 'Shop'
    end

    trait :shop do
      model_type 'Shop'
    end
  end
end
