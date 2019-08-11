describe SiteSelector do

  describe "#call" do

    let(:app) { ->(env) { [200, env, ["Dummy App"]] } }
    let(:middleware) { SiteSelector.new(app) }
    let(:site) { create :site, hostname: "test.localhost" }
    let(:url) { "http://#{site.hostname}" }

    context 'when liveness check' do

      it 'succeeds on valid URI' do
        code, env, body = middleware.call(Rack::MockRequest.env_for(url, { "REQUEST_URI" => "/liveness_check" }))
        expect(code).to eql(200)
        expect(body).to eql(['OK'])
        expect(env).not_to include('rack.errors')
      end

      it 'fails on invalid URI' do
        code, env, body = middleware.call(Rack::MockRequest.env_for(url, { "REQUEST_URI" => "/livenesss_check" }))
        expect(code).to eql(200)
        expect(body).to eql(['Dummy App'])
        expect(env).to include('rack.errors')
      end

    end

    context 'with X-SU-Forwarded-Host' do

      it 'sets Host to X-SU-Forwarded-Host' do
        code, env, body = middleware.call(Rack::MockRequest.env_for(url, { "HTTP_X_SU_FORWARDED_HOST" => "test-x-su.localhost" }))
        expect(code).to eql(200)
        expect(body).to eql(['Dummy App'])
        expect(env['HTTP_HOST']).to eql('test-x-su.localhost')
      end

    end

    context 'when readiness check' do

      it 'succeeds on valid URI' do
        code, env, body = middleware.call(Rack::MockRequest.env_for(url, { "REQUEST_URI" => "/readiness_check" }))
        expect(code).to eql(200)
        expect(body).to eql(['OK'])
        expect(env).not_to include('rack.errors')
      end

      it 'fails on invalid URI' do
        code, env, body = middleware.call(Rack::MockRequest.env_for(url, { "REQUEST_URI" => "/readinesss_check" }))
        expect(code).to eql(200)
        expect(body).to eql(['Dummy App'])
        expect(env).to include('rack.errors')
      end
    end

  end

end
