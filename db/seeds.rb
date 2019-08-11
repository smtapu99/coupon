# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

I18n.enforce_available_locales = false
country = Country.first || Country.create(
  name: 'Germany',
  locale: 'en',
)

site = Site.first || Site.create(
  name: 'First Site',
  hostname: 'localhost',
  country_id: country.id,
  time_zone: 'Berlin'
)

Site.current = site

Setting.create(site_id: Site.current.id) unless site.setting.present?

user = User.first || User.create(
  first_name: 'Admin',
  last_name: 'User',
  role: 'admin',
  email: 'admin@user.com',
  status: 'active',
  password: 'admin123',
  password_confirmation: 'admin123',
)
