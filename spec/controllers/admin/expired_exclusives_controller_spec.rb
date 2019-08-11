describe Admin::ExpiredExclusivesController do
  let!(:site) { create :site, hostname: 'test.host' }

  login_admin

  before do
    Site.current = site
  end

  describe 'GET index' do
    it 'assigns variables and renders index template' do
      get :index
      expect(assigns(:title)).to eq('Expired Exclusive Coupons')
      expect(response).to render_template('index')
    end

    context 'as format json' do
      it 'renders vue_grid json' do
        get :index, format: :json
        expect(JSON.parse(response.body)['page']).to eq(1)
      end
    end
  end

  describe 'GET edit' do

    it 'allows single id' do
      get :edit, params: { id: 1 }
      expect(assigns(:expired_exclusive).coupon_ids).to eq(['1'])
      expect(response).to render_template(partial: '_form')
    end

    it 'allows multiple ids' do
      get :edit, params: { ids: [1,2,3] }
      expect(assigns(:expired_exclusive).coupon_ids).to eq(['1','2','3'])
      expect(response).to render_template(partial: '_form')
    end
  end

  describe 'POST update' do

    let!(:coupons) { create_list :coupon, 2, is_exclusive: true }
    let(:new_date) { (Time.zone.now + 1.year).end_of_day.utc }

    before { Time.zone = 'UTC' }

    it 'it changes status and end_date on single coupons' do
      post :update, params: { expired_exclusive: { coupon_ids: [coupons.first.id], status: 'blocked', end_date: new_date.to_date.to_s(:db)  } }
      expect(flash[:notice]).to eq("Status and end date were applied to all affected coupons")
      expect(coupons.first.reload.end_date.utc.to_date).to eq(new_date.to_date)
    end

    it 'it changes status and end_date on multiple coupons' do
      post :update, params: { expired_exclusive: { coupon_ids: coupons.map(&:id), status: 'blocked', end_date: new_date.to_date.to_s(:db)  } }
      expect(flash[:notice]).to eq("Status and end date were applied to all affected coupons")
      expect(coupons.first.reload.end_date.utc.to_date).to eq(new_date.to_date)
    end
  end
end
