# Read about factories at https://github.com/thoughtbot/factory_girl

module Admin
  FactoryGirl.define do
    sequence(:coupon_affiliate_network_id) do |value|
      value
    end

    sequence(:coupon_country_id) do |value|
      value
    end

    sequence(:coupon_site_id) do |value|
      value
    end

    sequence(:coupon_shop_id) do |value|
      value
    end

    sequence(:coupon_title) do |value|
      "Coupon #{value}"
    end

    sequence(:coupon_mini_title) do |value|
      "Cpn #{value}"
    end

    sequence(:coupon_code) do |value|
      "CPN#{value}"
    end

    sequence(:coupon_url) do |value|
      "http://coupon-#{value}.com"
    end

    sequence(:coupon_logo) do |value|
      "coupon-#{value}.jpg"
    end

    sequence(:coupon_savings) do |value|
      value
    end

    sequence(:coupon_clicks) do |value|
      value
    end

    sequence(:coupon_order_position) do |value|
      value
    end

    sequence(:coupon_negative_votes) do |value|
      value
    end

    sequence(:coupon_positive_votes) do |value|
      value
    end

    factory :coupon do
      title { FactoryGirl.generate(:coupon_title) }

      shop { |r| Shop.first || r.association(:shop) }
      site { |r| Site.first || r.association(:site) }
      coupon_type 'offer'
      start_date (Time.zone.now - 5.hours)
      end_date (Time.zone.now + 7.days)
      url { FactoryGirl.generate(:coupon_url) }
      affiliate_network_id { FactoryGirl.generate(:coupon_affiliate_network_id) }

      factory :full_coupon do
        coupon_type 'coupon'
        title { FactoryGirl.generate(:coupon_title) }
        code { FactoryGirl.generate(:coupon_code) }
        logo { FactoryGirl.generate(:coupon_logo) }
        savings 1
        savings_in 'currency'
        is_exclusive 1
        is_free 1
        is_free_delivery 1
        is_mobile 1
        is_top 1
        logo_text_first_line 'First'
        logo_text_second_line 'Second'
        status 'active'
        clicks { FactoryGirl.generate(:coupon_clicks) }
        order_position { FactoryGirl.generate(:coupon_order_position) }
        negative_votes { FactoryGirl.generate(:coupon_negative_votes) }
        positive_votes { FactoryGirl.generate(:coupon_positive_votes) }
        created_at Time.zone.now.to_s(:db)
        updated_at Time.zone.now.to_s(:db)
      end

      factory :long_term_coupon do
        end_date (Time.zone.now + 70.days)
      end
    end
  end
end
