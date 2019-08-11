# Read about factories at https://github.com/thoughtbot/factory_girl

module Admin
  FactoryGirl.define do
    sequence(:country_name) do |value|
      "Country #{value}"
    end

    factory :country do
      name { FactoryGirl.generate(:country_name) }
      locale 'es-ES'
    end
  end
end
