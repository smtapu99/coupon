Frontend::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  config.action_controller.perform_caching = true

  # Default url options ~> Devise Gem
  config.action_mailer.default_url_options = { :host => 'pannacottagroup.com' }
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.perform_deliveries = true
  config.action_mailer.perform_caching = false
  config.action_mailer.smtp_settings = {
    address: 'smtp.mandrillapp.com',
    port: 2525,
    domain: 'pannacottagroup.com',
    authentication: :login,
    enable_starttls_auto: :true,
    user_name: 'luis.semprun@pannacottagroup.com',
    password: 'hSBZaMVIlGp6ZxdSbz9hEw'
  }

  config.middleware.use RoutesReloader
  config.middleware.use SiteSelector

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Allow usage on Vagrant
  if defined? BetterErrors
    # Allowing host
    host = ENV["SSH_CLIENT"] ? ENV["SSH_CLIENT"].match(/\A([^\s]*)/)[1] : nil
    BetterErrors::Middleware.allow_ip! host if [:development, :test].member?(Rails.env.to_sym) && host
  end
end
