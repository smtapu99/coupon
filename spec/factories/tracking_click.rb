FactoryGirl.define do
  factory :tracking_click, class: TrackingClick do
    association :tracking_user
    association :site

    trait :with_tracking_click_in do
      landing_page 'landing_page'
      click_type 'click_in'
      page_type 'path/controller'
      utm_source 'extract_query_param(:utm_source)'
      utm_campaign 'extract_query_param(:utm_campaign)'
      utm_medium 'extract_query_param(:utm_medium)'
      utm_term 'extract_query_param(:utm_term)'
      channel 'extract_channel(origin_referrer, params)'
    end
  end
end
