describe CategoriesController do
  include ApplicationHelper

  let(:site) { create :site, hostname: 'test.host' }

  describe "GET 'index'" do
    before { create :setting_routes, site_id: site.id }
    subject { get 'index' }
    it { is_expected.to have_http_status 200 }
  end

  describe "GET 'show'" do
    before { default_url_options[:host] = site.hostname }

    context 'with existing active category' do
      let(:category) { create :category, site_id: site.id }
      subject { get :show, params: { slug: category.slug } }
      it { is_expected.to have_http_status 200 }
    end

    context 'with gone category' do
      let(:category) { create :category, site_id: site.id, status: 'gone' }
      subject { get :show, params: { slug: category.slug } }
      it { is_expected.to have_http_status 404 }
    end

    context 'with pending category' do
      let(:category) { create :category, site_id: site.id, status: 'pending' }
      subject { get :show, params: { slug: category.slug } }
      it { is_expected.to redirect_to root_url }
    end

    context 'with blocked category' do
      let(:category) { create :category, site_id: site.id, status: 'blocked' }
      subject { get :show, params: { slug: category.slug } }
      it { is_expected.to redirect_to root_url }
    end

    context 'with paginate_categories' do

      let!(:setting) { create :setting_site, site: site }
      let!(:category) { create :category, site_id: site.id }
      let!(:coupons) { create_list :coupon, 40, site: site, categories: [category] }

      it 'true, it shows pagination' do
        get :show, params: { slug: category.slug }
        expect(assigns(:coupons).size).to eq(10)
        expect(assigns(:coupons).respond_to?(:total_pages)).to eq(true)
      end

      it 'false, it hides pagination and shows 25 coupons' do
        setting.publisher_site.paginate_categories = 0
        setting.save
        get :show, params: { slug: category.slug }
        expect(assigns(:coupons).size).to eq(25)
        expect(assigns(:coupons).respond_to?(:total_pages)).to eq(false)
      end
    end
  end
end
