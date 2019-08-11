# Read about factories at https://github.com/thoughtbot/factory_girl

module Admin
  FactoryGirl.define do

    sequence(:category_origin_id) do |value|
      value
    end

    sequence(:category_name) do |value|
      "Category #{value}"
    end

    sequence(:category_slug) do |value|
      "category-#{value}"
    end

    sequence(:category_css_icon_class) do |value|
      "icon-#{value}"
    end

    sequence(:category_ranking_value) do |value|
      "#{value}"
    end

    factory :category do
      site { |r| Site.first || r.association(:site) }
      origin_id { FactoryGirl.generate(:category_origin_id) }
      name { FactoryGirl.generate(:category_name) }
      slug { FactoryGirl.generate(:category_slug) }
      css_icon_class { FactoryGirl.generate(:category_css_icon_class) }
      status 'active'
      main_category true
      ranking_value { FactoryGirl.generate(:category_ranking_value) }
      created_at Time.zone.now.to_s(:db)
      updated_at Time.zone.now.to_s(:db)
      association :html_document, factory: :html_document

      factory :main_category do
        main_category true
      end

      trait :with_html_document_noindex do
        association :html_document, :with_noindex
      end

      trait :with_html_document_index do
        association :html_document, :with_index
      end

    end
  end
end
