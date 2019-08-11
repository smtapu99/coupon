describe Admin::AlertsController do
  let!(:site) { create :site, hostname: 'test.host' }

  login_admin

  before do
    Site.current = site
  end

  describe 'GET index' do
    it 'returns 200' do
      get :index
      expect(response.code).to eq("200")
    end

    context 'as format json' do
      it 'renders vue_grid json' do
        get :index, format: :json
        expect(JSON.parse(response.body)['page']).to eq(1)
      end
    end
  end

  describe 'POST destroy' do
    let!(:alert) { create :alert }

    context 'as format json' do
      it 'renders vue_grid json' do
        get :index, format: :json
        expect(JSON.parse(response.body)['page']).to eq(1)
      end
    end
  end
end
