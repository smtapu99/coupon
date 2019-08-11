FactoryGirl.define do
  factory :category_tag do
    association :category, factory: :category
    association :tag, factory: :tag
  end
end
