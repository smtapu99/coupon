class SiteSelector

  def initialize(app)
    @app = app
  end

  def call(env)

    if ['/liveness_check', '/readiness_check'].include?(env['REQUEST_URI'])
      return [ 200, { "Content-Type" => "text/plain" }, ["OK"] ]
    end

    if env['HTTP_X_SU_FORWARDED_HOST'].present?
      env['HTTP_HOST'] = env['HTTP_X_SU_FORWARDED_HOST']
    end

    begin
      @app.call(env)
    rescue StandardError => error
      if env['HTTP_ACCEPT'] =~ /application\/json/
        error_output = "Invalid JSON submission: #{error}"
        return [
          400, { "Content-Type" => "application/json" },
          [ { status: 400, error: error_output }.to_json ]
        ]
      else
        raise error
      end
    end
  end
end
