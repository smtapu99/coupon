FactoryGirl.define do

  sequence(:static_page_slug) do |value|
    "slug-example-#{value}"
  end

  factory :static_page do

    title 'title-example'
    slug  { FactoryGirl.generate(:static_page_slug) }

  end
end
