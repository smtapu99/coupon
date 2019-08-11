FactoryGirl.define do

  factory :widget_area do
    site { |r| Site.first || r.association(:site) }
    # area 1
    name 'main'

    factory :widget_area_sidebar do
      name 'sidebar'
    end

    factory :widget_area_footer do
      name 'footer'
    end
  end
end
