describe Admin::ShopsController do
  let!(:site) { create :site, hostname: 'test.host' }

  login_admin

  before do
    site.setting = Setting.new
    Site.current = site
  end

  describe 'GET index' do
    it 'returns 200' do
      get :index
      expect(response.code).to eq("200")
    end
  end

  describe 'POST update' do
    let!(:shop) { create :shop, site: site }
    subject { post :update, params: { id: shop.id, shop: { title: 'New Name' } } }
    it { is_expected.to have_http_status 302 }

    it 'updates shop.attributes' do
      subject
      expect(Shop.first.title).to eq('New Name')
    end
  end

  describe 'GET order_coupons' do
    let!(:shop) { create :shop, site: site }
    let!(:coupon) { create :coupon, site: site, shop: shop }

    subject { get :order_coupons, params: { id: shop.id } }
    it { is_expected.to have_http_status 200 }

    it 'assings' do
      subject
      expect(assigns(:site)).to be_a(SiteFacade)
      expect(assigns(:settings)).to eq(SiteFacade.new(site).settings)
      expect(assigns(:coupons)).to eq(Coupon.where(shop_id: shop.id))
    end
  end

  describe 'POST update_coupon_order' do
    let!(:shop) { create :shop, site: site, id: 1000 }
    let!(:coupons) { create_list :coupon, 2, site: site, shop: shop }

    subject { post :update_coupon_order, params: { coupon_order: [coupons.last.id, coupons.first.id] } }
    it { is_expected.to have_http_status 200 }

    it 'updates shop.order_position' do
      subject
      expect(Coupon.first.order_position).to eq(1)
      expect(Coupon.last.order_position).to eq(0)
    end
  end

  describe 'POST update_shop_list_priority' do
    let!(:shop) { create :shop, site: site, id: 1000 }
    let!(:coupons) { create_list :coupon, 2, site: site, shop: shop }

    subject { post :update_shop_list_priority, params: { id: shop.id, shop_list_priority: { coupons.first.id => 10 } } }
    it { is_expected.to have_http_status 302 }

    it 'updates shop.order_position' do
      subject
      expect(Coupon.first.shop_list_priority).to eq(10)
    end
  end

  describe 'GET change_status' do
    let!(:shop) { create :shop, site: site, id: 1000 }
    subject { get :change_status, params: { ids: [shop.id], status: 'blocked' } }
    it { is_expected.to have_http_status 200 }

    it 'updates shop.order_position' do
      subject
      expect(Shop.first.status).to eq('blocked')
    end
  end
end
