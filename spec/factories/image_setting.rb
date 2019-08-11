FactoryGirl.define do
  factory :image_setting do
    association :site, factory: [:site]
  end
end
