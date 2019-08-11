FactoryGirl.define do
  factory :medium do
    association :site, factory: [:site]
    file_name File.open(Rails.root.join("spec/files/test.png"))
  end
end
