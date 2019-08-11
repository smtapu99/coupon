FactoryGirl.define do

  factory :vote do
    association :shop, factory: [:shop]
    stars 2
  end

end
