module Admin
  FactoryGirl.define do
    sequence(:shop_import_id) do |value|
      value
    end

    sequence(:shop_import_status) do |value|
      value
    end

    factory :campaign_import do
      id { FactoryGirl.generate(:shop_import_id) }
      user { |r| User.first || r.association(:user) }
      status { FactoryGirl.generate(:shop_import_status) }
      created_at Time.zone.now.to_s(:db)
    end
  end
end
