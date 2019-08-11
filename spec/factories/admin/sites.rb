# Read about factories at https://github.com/thoughtbot/factory_girl

module Admin
  FactoryGirl.define do
    sequence(:name) do |value|
      "Site #{value}"
    end

    sequence(:hostname) do |value|
      "site-#{value}.com"
    end

    factory :site do
      country { |r| Country.first || r.association(:country) }
      name
      hostname
      time_zone 'Berlin'
      status 'active'

      # Try To Remove This
      factory :sites_with_country, parent: :site do
        name { generate(:site_name) }
        hostname { generate(:site_hostname) }
        country { |r| Country.first || r.association(:country) }
      end

      # Try To Remove This
      factory :another_site do
        name 'Cupom.com'
        hostname 'cupom.com'
        country { |r| (Country.count >= 2) ? Country.last : FactoryGirl.create(:country) }
      end

      factory :site_with_setting do
        setting { |r| create(:setting) }
      end
    end
  end
end

# OLD CODE
# FactoryGirl.define do
#   sequence(:site_name) { |sn| "site_name_#{sn}" }
#   sequence(:site_hostname) { |sh| "site_host_#{sh}.com" }
# end

# FactoryGirl.define do

#   factory :site do

#     name { FactoryGirl.generate(:site_name) }
#     hostname { FactoryGirl.generate(:site_hostname) }
#     countries {[FactoryGirl.create(:country)]}

#     factory :sites_with_country, parent: :site do
#       name { generate(:site_name) }
#       hostname { generate(:site_hostname) }
#       countries {[FactoryGirl.create(:country_enum)]}
#     end

#     factory :another_site do
#       name 'Cupom.com'
#       hostname 'cupom.com'
#       countries {[FactoryGirl.create(:country)]}
#     end
#   end
# end
