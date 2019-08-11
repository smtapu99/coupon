FactoryGirl.define do

  factory :site_custom_translation do
    association :translation, factory: [:translation]
    association :site, factory: [:site]
    value 'custom_value'
  end
end
