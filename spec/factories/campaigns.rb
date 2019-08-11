# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  sequence(:campaign_name) do |value|
    "Campaign #{value}"
  end

  sequence(:campaign_slug) do |value|
    "campaign_#{value}"
  end

  factory :campaign do
    status 'active'
    site { |r| Site.first || r.association(:site) }
    name { FactoryGirl.generate(:campaign_name) }
    slug { FactoryGirl.generate(:campaign_slug) }
    nav_title "MyString"
    h1_first_line "MyString"
    h1_second_line "MyString"
    blog_feed_url "MyString"
    box_color "MyString"
    coupon_filter_text "MyString"
    text "MyString"
    text_headline "MyString"
    start_date Time.zone.now - 1.day
    end_date Time.zone.now + 10.days

    association :html_document, factory: :html_document

    trait :with_html_document_noindex do
      association :html_document, :with_noindex
    end

    trait :with_html_document_index do
      association :html_document, :with_index
    end
  end
end
