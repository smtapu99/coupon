describe Admin::CategoriesController do
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
  end

  describe 'POST update' do
    let!(:category) { create :category, site: site }
    subject { post :update, params: { id: category.id, category: { name: 'New Name' } } }
    it { is_expected.to have_http_status 302 }

    it 'updates category.order_position' do
      subject
      expect(Category.first.name).to eq('New Name')
    end
  end

  describe 'GET order' do
    subject { get :order }
    it { is_expected.to have_http_status 200 }

    it 'assings categories' do
      subject
      expect(assigns(:categories)).to eq(Site.current.categories)
    end
  end

  describe 'POST order' do
    let!(:category) { create :category, site: site, id: 1000 }
    subject { post :update_order, params: { order_position: { category.id => 1 } } }
    it { is_expected.to have_http_status 200 }

    it 'updates category.order_position' do
      subject
      expect(Category.first.order_position).to eq(1)
    end
  end

  describe 'GET change_status' do
    let!(:category) { create :category, site: site, id: 1000 }
    subject { get :change_status, params: { ids: [category.id], status: 'blocked' } }
    it { is_expected.to have_http_status 200 }

    it 'updates category.order_position' do
      subject
      expect(Category.first.status).to eq('blocked')
    end
  end
end
