FactoryGirl.define do

  factory :option do
    association :site, factory: [:site]
  end
end
