describe Admin::QualityController do
  let!(:site) { create :site, hostname: 'test.host' }

  login_admin

  before do
    Site.current = site
  end

  describe 'GET active_coupons' do
    it 'assigns variables and renders index template' do
      get :active_coupons
      expect(assigns(:title)).to eq('Active Coupons per Shop')
      expect(assigns(:info)).to eq('Overview of how many active coupons the shop has today / in 3 days / in 7 days.')
      expect(response).to render_template('index')
    end

    context 'as format json' do
      it 'renders vue_grid json' do
        get :active_coupons, format: :json
        expect(JSON.parse(response.body)['page']).to eq(1)
      end
    end
  end

  describe 'GET invalid_urls' do
    it 'renders index template' do
      get :invalid_urls
      expect(assigns(:title)).to eq('Wrong Affiliate Networks')
      expect(assigns(:info)).to eq('Overview of coupons where the URL doesnt match with the Validation Regex of the Affiliate Network.')
      expect(response).to render_template('index')
    end

    context 'as format json' do
      it 'renders vue_grid json' do
        get :active_coupons, format: :json
        expect(JSON.parse(response.body)['page']).to eq(1)
      end
    end
  end

end
