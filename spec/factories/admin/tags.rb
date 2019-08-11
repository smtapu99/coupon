FactoryGirl.define do
  sequence(:tag_word) do |value|
    "tag #{value}"
  end

  factory :tag do
    association :site
    word { FactoryGirl.generate(:tag_word) }
  end
end
