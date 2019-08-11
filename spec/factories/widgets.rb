FactoryGirl.define do


  sequence(:widget_title) do |value|
    "Widget #{value}"
  end

  factory :widget do
    site { |r| Site.first || r.association(:site) }
    title { FactoryGirl.generate(:widget_title) }
    name 'text'

    factory :widget_category do
      name 'category'
      # FIXME: this calles the method categories from the rebatly.rake-task
      #        -> completly wrong and destroyed the migrations!
      # categories ['1']
    end

    factory :widget_newsletter do
      name 'newsletter'
    end

    factory :featured_coupons_widget do
      name 'featured_coupons'
    end

  end
end
