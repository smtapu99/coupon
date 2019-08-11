# Read about factories at https://github.com/thoughtbot/factory_girl
module Admin
  FactoryGirl.define do
    sequence(:shop_site_id) do |value|
      value
    end

    sequence(:shop_merchant_id) do |value|
      value
    end

    sequence(:shop_link_title) do |value|
      "http://shop-#{value}.com/link-title"
    end

    sequence(:shop_header_image) do |value|
      "header-image-#{value}.jpg"
    end

    sequence(:shop_logo) do |value|
      "logo-#{value}.jpg"
    end

    sequence(:shop_logo_cropped) do |value|
      "logo-cropped-#{value}.jpg"
    end

    sequence(:shop_logo_alt_text) do |value|
      "Logo #{value}"
    end

    sequence(:shop_logo_title_text) do |value|
      "Logo #{value}"
    end

    sequence(:title) do |value|
      "Title #{value}"
    end

    sequence(:slug) do |value|
      "slug-#{value}"
    end

    sequence(:url) do |value|
      "http://shop-#{value}.com"
    end

    sequence(:fallback_url) do |value|
      "http://fallback-#{value}.com"
    end

    factory :shop do
      status 'active'
      association :global
      site { |r| Site.first || r.association(:site) }
      title
      slug
      url
      fallback_url
      info_delivery_methods Option::get_select_options(:delivery_methods).values
      info_payment_methods Option::get_select_options(:payment_methods).values

      factory :shop_with_header_image do
        header_image File.open(File.join(Rails.root, 'spec/files/test.png'))
      end

      factory :hidden_shop do
        is_hidden true
      end

      trait :with_html_document_noindex do
        association :html_document, :with_noindex
      end

      trait :with_html_document_index do
        association :html_document, :with_index
      end

      trait :with_html_document_robots_nil do
        association :html_document, meta_robots: nil
      end

      trait :with_wrong_delivery_methods do
        info_delivery_methods ['wrong_delivery_method_1', 'wrong_delivery_method_2']
      end

      trait :with_wrong_payment_methods do
        info_payment_methods ['wrong_payment_method_1', 'wrong_payment_method_2']
      end
    end
  end
end
