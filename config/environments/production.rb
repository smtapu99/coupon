Frontend::Application.configure do

  # Settings specified here will take precedence over those in config/application.rb.
  config.action_mailer.default_url_options = { :host => 'pannacottagroup.com' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default :charset => "utf-8"

  config.action_mailer.smtp_settings = {
    address: 'smtp.mandrillapp.com',
    port: 2525, #587 is blocked by google cloud instances
    domain: 'pannacottagroup.com',
    authentication: :login,
    enable_starttls_auto: :true,
    user_name: 'luis.semprun@pannacottagroup.com',
    password: 'hSBZaMVIlGp6ZxdSbz9hEw'
  }

  config.middleware.use RoutesReloader
  config.middleware.use SiteSelector

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both thread web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like nginx, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable Rails's static asset server (Apache or nginx will already do this).
  config.public_file_server.enabled = true

  #config.action_controller.default_asset_host_protocol = :relative
  #config.default_asset_host_protocol = :relative

  # Static cache control
  config.public_file_server.headers = { 'Cache-Control' => "public, max-age=#{1.week.to_i}" }

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true
  config.ssl_options = {
    hsts: false,
    redirect: {
      exclude: -> request { request.path =~ /^\/api\/v1\/cron\/[a-z_]*$/i }
    }
  }

  # Set to :debug to see everything in the log.
  config.log_level = :warn

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  config.assets.enabled = true

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Disable automatic flushing of the log to improve performance.
  # config.autoflush_log = false


  config.logger = Logger.new(STDOUT)
  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new
end
