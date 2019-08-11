require File.expand_path('../boot', __FILE__)

require 'csv'
require 'iconv'
require 'rails/all'
require 'grape/rabl'
require 'rack-rewrite'
require_relative '../lib/redirector/middleware'


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Frontend
  class Application < Rails::Application

    # READ ENV VARIABLES FROM FILE FOR RUNNING PRODUCTION ON LOCALHOST
    config.before_configuration do
      env_template = ERB.new File.new(Rails.root.join('config', 'env.yml')).read
      YAML.load(env_template.result(binding)).each do |key, value|
        ENV[key.to_s] = value
      end
    end unless Rails.env.production?

    # this allows asset_sync to work with google cloud on cnamed buckets like
    # https://github.com/fog/fog/issues/2357
    Fog.credentials = { path_style: true }

    # # allow redirections also matching the query string
    # config.redirector.include_query_in_source = true
    config.redirector.preserve_query = false
    config.redirector.ignored_patterns = [
      /^\/assets\/.+/,
      /^\/assets\/.+/,
      /^\/admin\/.+/,
      /^\/pcadmin\/.+/,
      /^\/tracking\/.+/,
      /^\/ajaxs\/.+/,
      /^\/shops\/render_votes.+/,
      /^\/shops\/vote.+/
    ]

    config.time_zone = 'Berlin'
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en
    config.i18n.available_locales = [
     :en,
     'en-GB',
     'en-US',
     'de-DE',
     'es-CL',
     'es-CO',
     'es-ES',
     'es-MX',
     'fr-FR',
     'it-IT',
     'nl-NL',
     'pt-BR',
     'pl-PL',
     'ru-RU',
     'ru-UA',
     'tr-TR'
    ]

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.action_controller.permit_all_parameters = true
    config.autoload_paths += %W(#{config.root}/lib)
    config.assets.paths << Rails.root.join(Rails.root, 'app', 'assets', 'themes').to_s
    config.assets.paths << Rails.root.join(Rails.root, 'vendor', 'assets', 'stylesheets').to_s
    config.assets.paths << Rails.root.join(Rails.root, 'vendor', 'assets', 'javascripts').to_s

    # this line is used by jquery-lazy-images gem
    config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif)
    # config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/

    config.exceptions_app = self.routes

    # config.assets.paths << Rails.root.join("app/sites/gutscheinedailydealde/assets/stylesheets").to_s
    # config.assets.precompile += ["localhost.css", "gutscheinedailydealde.css"]

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # forward urls with trailing slashes to without trailing slashes
    config.middleware.insert_before(Rack::Runtime, Rack::Rewrite) do
      r301 %r{(.+)/$}, '$1'
    end

    config.middleware.use(Rack::Config) do |env|
      env['api.tilt.root'] = Rails.root.join "app", "api", "views"
    end

    cs_template = ERB.new File.new(Rails.root.join('config', 'services.yml')).read
    config.custom_services = YAML.load(cs_template.result(binding))

    if Rails.env.production?
      redis_url = "redis://#{config.custom_services["redis_server"]}:#{config.custom_services["redis_port"]}/0/cache"
      config.cache_store = :redis_cache_store, { url: redis_url, expires_in: 240.minutes }
      config.action_controller.asset_host = "//#{config.custom_services['assets_domain']}";
    else
      redis_url = "redis://#{ENV['REDIS_HOST'] ||= 'localhost'}:#{ENV['REDIS_PORT'] ||= 6379}/0/cache"
      config.cache_store = :redis_cache_store, { url: redis_url, expires_in: 90.minutes }
    end

    config.session_store = :cache_store, { key: '_foundation_sessions', namespace: 'sessions' }

    config.gem 'liquid'

    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.view_specs false
      g.helper_specs false
      g.stylesheets = false
      g.javascripts = false
      g.helper = false
    end

    config.action_view.sanitized_allowed_tags = []
  end
end
