module Admin
  FactoryGirl.define do
    factory :tag_import do
      association :site, factory: :site
      file File.open(Rails.root.join('spec/support/files/tag_import.xlsx'))
    end
  end
end
