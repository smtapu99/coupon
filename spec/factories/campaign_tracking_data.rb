FactoryGirl.define do
  factory :campaign_tracking_data, class: 'CampaignTrackingData' do
    data {{ gclid: '74152', campaign_id: 52, adgroup_id: 85, keyword: 'bumsegal'}}
    association :tracking_click, :with_tracking_click_in
  end
end
