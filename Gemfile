Encoding.default_external = Encoding::UTF_8

source 'https://rubygems.org'
ruby '2.6.3'

gem 'bootsnap', require: false
gem 'data_migrate', '~> 4.0'

gem "activerecord-nulldb-adapter"

gem 'rack', '~> 2.0.6'
gem 'redirector', '~> 1.1.1'
gem 'rack-rewrite'

# Rails Server alternative to WebRick
gem 'puma'

gem 'foreman'

gem "autoprefixer-rails"

# New Relic
gem 'newrelic_rpm'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.2.2'
gem 'rails-i18n'
gem 'rails-html-sanitizer', '~> 1.0.4'

# Use mysql as the database for Active Record
gem 'mysql2', '~> 0.5.0'

# Used to deeply merge hashes
gem 'deep_merge', require: 'deep_merge/rails_compat'

# Resque for background tasks using Redis
gem 'sinatra', '2.0.3'

# TODO: remove resque github dependency as soon as 2.0 is released
gem 'resque', '2.0.0'

# Use SCSS for stylesheets
gem 'sass-rails'
gem 'request_store'
gem 'tinymce-rails', '4.1.6'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'

# Geo information
gem 'geoip'

# User Authentication
gem 'devise', '~> 4.6.0'
gem 'cancancan'

# Image Uploading
gem 'carrierwave'
gem 'kraken-io'
gem 'parallel'  # paralell multi thread procession
gem 'rmagick'
gem 'fog'
gem 'fog-google'
gem 'google-api-client'
gem 'nokogiri', '~> 1.10.2'
gem 'mime-types'

# Google Drive
gem 'google_drive'

# Mailchimp
gem 'gibbon'
gem 'mail_form'

# CSV Importer
gem 'roo', '~> 2.7.1'
gem 'iconv'

# XLS Export
gem 'axlsx', '3.0.0.pre'
gem 'axlsx_rails', '0.5.2'
gem 'rubyzip', '~> 1.2.2'

# Unidecoder is a Gem to handle slugs and transliterate strings
gem 'unidecoder'

gem 'active_enum', '~> 1.0.0.pre'
gem 'groupdate'
gem 'active_median'

# used for import of old data
gem 'activerecord-import'
gem 'viva-php_serialize'
gem 'work_queue'

gem 'rails_real_favicon'
gem 'coffee-rails'

gem 'link_scout'

group :development do
  gem 'bullet'
  gem 'rubocop'
  gem 'better_errors', '~> 2.4'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'letter_opener'
end

# Use ActiveModel has_secure_password
gem 'bcrypt'

# Use debugger
group :development, :test do
  gem 'pry'
end

group :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'rails-controller-testing'
  gem 'webmock', '~> 3.4'
  gem 'database_cleaner'
  gem 'coveralls', require: false
  gem 'rspec-html-matchers'
end

# Api
gem 'grape'
gem 'grape-rabl'

# Cache
# TODO: Remove with Rails 5.2, redis-rails has announced EOL
gem 'redis', '~> 4.0'

gem 'fastly'
gem 'cloudflare'

##################
# FRONTEND
##################
gem 'liquid'
gem 'codemirror-rails'
#gem 'asset_sync' #Synchronises Assets between Rails and S3.

##################
# Reverse Proxy
##################
gem 'rack-reverse-proxy', require: 'rack/reverse_proxy'

gem "algoliasearch-rails", "~> 1.22.0"

gem 'kaminari'

gem 'modernizr-rails'
gem 'content_for_in_controllers'

gem 'cookies_eu'

gem 'themes_on_rails'

gem 'utf8-cleaner'

gem 'webpacker', '~> 4.x'

gem 'active_model_otp'
gem 'rqrcode'
