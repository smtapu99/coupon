describe ExternalUrlsController, type: :controller do
  include ExternalUrlHelper

  let!(:site) { create :site, hostname: 'test.host' }
  let!(:external_url) { ExternalUrl.create(url: 'https://test.de') }

  before { DynamicRoutes.reload }

  context 'when params[:id].blank?' do
    subject { get :out, params: { id: '' } }
    it { is_expected.to have_http_status 503 }
  end
  context 'when params[:id] wrong' do
    subject { get :out, params: { id: 9999999 } }
    it { is_expected.to have_http_status 404 }
  end

  context 'when params[:id].present?' do
    subject { get :out, params: { id: external_url.id } }
    it { is_expected.to have_http_status 307 }
  end

  context 'when reduced_js_features' do
    let!(:setting) { create :setting, publisher_site: { reduced_js_features: '1' }}
    subject { get :out, params: { id: external_url.id } }
    it { is_expected.to have_http_status 200 }
    it { is_expected.to render_template("out") }
  end
end
