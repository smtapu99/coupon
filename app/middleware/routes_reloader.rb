class RoutesReloader
  SKIPPED_PATHS = ['/assets/', '/admin/', '/pcadmin/']

  def initialize(app)
    @app = app
  end

  def call(env)
    if reload_required?(env)
      timestamp = Rails.cache.read("#{request_host(env)}_rcts")

      if timestamp.present? && Thread.current[:routes_timestamp] != timestamp
        Rails.application.reload_routes!

        Thread.current[:routes_timestamp] = timestamp
      end
    end

    @app.call(env)
  end

  private

  def request_host(env)
    env['HTTP_HOST'].split(':').first
  end

  def reload_required?(env)
    SKIPPED_PATHS.none? { |path| env['PATH_INFO'].include?(path) }
  end
end
