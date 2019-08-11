workers Integer(ENV['WEB_CONCURRENCY'] || 1)
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 1)

threads threads_count, threads_count

# stdout_redirect "/proc/self/fd/2", "/proc/self/fd/2", true

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RAILS_ENV'] || 'development'

if ENV['RAILS_ENV'] == 'development'
  worker_timeout 600
end

# on_worker_boot do
#   # Worker specific setup for Rails 4.1+
#   # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
#   ActiveRecord::Base.establish_connection
# end

on_worker_boot do
  # Valid on Rails up to 4.1 the initializer method of setting `pool` size
  begin
    ActiveRecord::Base.establish_connection
  rescue
    p "Probably executing resque worker health check, otherwise check puma.rb"
  end
  if defined?(Resque)
    redis_url = "redis://#{ENV['REDIS_HOST'] || "127.0.0.1"}:#{ENV['REDIS_PORT'] || "6379"}"
    Resque.redis = redis_url
  end
end
