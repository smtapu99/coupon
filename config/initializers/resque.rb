rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

if rails_env == 'production'
  Resque.redis = "redis://#{Frontend::Application.config.custom_services["redis_server"]}:#{Frontend::Application.config.custom_services["redis_port"]}/0/cache"
else
  Resque.redis = "#{ENV['REDIS_HOST'] ||= 'localhost'}:#{ENV['REDIS_PORT'] ||= '6379'}"
end

# reload routes when a new site is created
Resque.before_fork do |job|
  begin
    send("root_#{Site.last.id}_url")
  rescue NameError => e
    p 'Reloading Routes'
    Rails.application.reload_routes!
  end
end
