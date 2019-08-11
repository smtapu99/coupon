require 'rails_helper'

describe Redirector do
  let(:site) { create :site, hostname: 'test.host' }

  describe "#call" do
    let(:app) { ->(env) { [200, env, ["Dummy App"]] } }
    let(:middleware) { Redirector::Middleware.new(app) }
    let(:url) { "http://#{site.hostname}" }

    context 'when ignored' do
      let!(:rule) { create :redirect_rule, source: '/tracking/set', destination: '/destination', site_id: site.id }
      let!(:environment_rule) { create :request_environment_rule, environment_value: 'test.host', redirect_rule: rule }

      it 'doesnt redirect' do
        code, env, body = middleware.call(Rack::MockRequest.env_for(url, 'PATH_INFO' => '/tracking/set', 'HTTP_HOST' => 'test.host'))
        expect(code).to eql(200)
        expect(body).to eql(['Dummy App'])
      end
    end

    context 'when redirect_rule exists' do
      let!(:rule) { create :redirect_rule, source: '/source', destination: '/destination', site_id: site.id }
      let!(:environment_rule) { create :request_environment_rule, environment_value: 'test.host', redirect_rule: rule }

      it 'redirects to https if host != cupones.europapress.es' do
        code, env, body = middleware.call(Rack::MockRequest.env_for(url, 'PATH_INFO' => '/source', 'HTTP_HOST' => 'test.host'))
        expect(code).to eql(301)
        expect(env['Location']).to eql('https://test.host/destination')
      end

      context 'and https' do
        it 'redirects to https' do
          code, env, body = middleware.call(Rack::MockRequest.env_for(url, 'PATH_INFO' => '/source', 'HTTP_HOST' => 'test.host'))
          expect(code).to eql(301)
          expect(env['Location']).to eql('https://test.host/destination')
        end
      end
    end

    context 'with invalid URI (special characters)' do
      let(:path_with_params) { '/source?param1=1&params2=2/||' }

      it 'raises no errors' do
        code, env, body = middleware.call(Rack::MockRequest.env_for(url, 'PATH_INFO' => '/source/|', 'HTTP_HOST' => 'test.host'))
        expect(code).to eql(200)
      end

      context 'when redirection exists' do
        let!(:rule) { create :redirect_rule, source: '/source?param1=1&params2=2/||', destination: '/destination', site_id: site.id }
        let!(:environment_rule) { create :request_environment_rule, environment_value: 'test.host', redirect_rule: rule }

        it 'redirects' do
          code, env, body = middleware.call(Rack::MockRequest.env_for(url, 'PATH_INFO' => path_with_params, 'HTTP_HOST' => 'test.host'))
          expect(code).to eql(301)
        end
      end
    end
  end
end
