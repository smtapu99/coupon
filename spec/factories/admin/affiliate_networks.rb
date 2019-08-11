# Read about factories at https://github.com/thoughtbot/factory_girl

module Admin
  FactoryGirl.define do
    sequence(:affiliate_network_name) do |value|
      "Affiliate Network #{value}"
    end

    sequence(:affiliate_network_slug) do |value|
      "affiliate-network-#{value}"
    end

    factory :affiliate_network do
      name { FactoryGirl.generate(:affiliate_network_name) }
      slug { FactoryGirl.generate(:affiliate_network_slug) }
      status AffiliateNetwork.statuses[:active]
    end
  end
end
