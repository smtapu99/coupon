require 'rails_helper'

describe ShopsController do
  include RSpecHtmlMatchers
  include ApplicationHelper

  let!(:site) { create :site, hostname: 'test.host' }
  let!(:shop) { create :shop, site_id: site.id }
  let!(:setting) { create :setting_routes, site_id: site.id }

  describe "GET 'render_votes'" do

    it "returns not_found unless id is present" do
      get :render_votes
      expect(response.status).to eq 404
    end

    it "returns not_found unless id is integer" do
      get :render_votes, params: { id: 'abc' }
      expect(response.status).to eq 404
    end

    it "returns not_found if id is present and format is html" do
      get :render_votes, params: { id: shop.id }
      expect(response.status).to eq 404
    end

    describe 'with xhr' do
      let(:tu) { create :tracking_user }

      it "fails if shop doesnt exist" do
        get :render_votes, params: { id: 123456 }, xhr: true
        expect(response.status).to eq 404
      end

      it "success if shop exists and existing vote doesnt exist" do
        get :render_votes, params: { id: shop.id }, xhr: true
        expect(response.status).to eq 200
      end

      it "success if vote exist" do
        shop.add_vote(5, tu.uniqid)
        get :render_votes, params: { id: shop.id }, xhr: true
        expect(response.status).to eq 200
      end
    end
  end

  describe "GET 'index'" do
    it 'returns http success' do
      get :index
      expect(response.status).to eq 200
    end

    context 'view' do
      render_views
      it 'has meta robots index,follow' do
        get :index
        expect(response.body).to have_tag('meta', with: { name: 'robots', content: 'index,follow' })
      end
    end
  end

  describe "GET 'show'" do
    before do
      @site = SiteFacade.new(site)
      default_url_options[:host] = @site.site.hostname
    end

    it '200 if shop exists and active' do
      get :show, params: { slug: shop.slug }
      expect(response.status).to eq 200
    end

    it '301 to itself if page present' do
      get :show, params: { slug: shop.slug, page: 2 }
      expect(response).to redirect_to send("shop_show_#{site.id}_url", slug: shop.slug)
    end

    it '404 if shop is gone' do
      shop.update(status: 'gone')
      get :show, params: { slug: shop.slug }
      expect(response.status).to eq 404
    end

    it '301 to homepage if shop is pending' do
      shop.update(status: 'pending')
      get :show, params: { slug: shop.slug }
      expect(response).to redirect_to root_url
    end

    it '301 to homepage if shop is blocked' do
      shop.update(status: 'blocked')
      get :show, params: { slug: shop.slug }
      expect(response).to redirect_to root_url
    end

    context 'if category present? 301 to category if' do
      let!(:category) { create :category }
      let!(:category_url) { dynamic_url_for('categories', 'show', slug: category.slug, parent_slug: category.parent_slug) }

      before { shop.shop_categories = [category] }

      it 'gone' do
        shop.update(status: 'gone')
        get :show, params: { slug: shop.slug }
        expect(response).to redirect_to(category_url)
      end

      it 'blocked' do
        shop.update(status: 'blocked')
        get :show, params: { slug: shop.slug }
        expect(response).to redirect_to(category_url)
      end

      it 'pending' do
        shop.update(status: 'pending')
        get :show, params: { slug: shop.slug }
        expect(response).to redirect_to(category_url)
      end
    end
  end

  context 'expired coupons with hide_expired_coupons setting' do
    render_views

    let!(:coupon) { create :coupon, site_id: site.id, end_date: (Time.zone.now - 1.day) }

    it 'on, hides expired coupons' do
      site.setting.update(publisher_site: { hide_expired_coupons: '1' })
      get :show, params: { slug: shop.slug }
      expect(response.body).not_to include('card-expired-coupons-list')
    end

    it 'off, shows expired coupons' do
      site.setting.update(publisher_site: { hide_expired_coupons: '0' })
      get :show, params: { slug: shop.slug }
      expect(response.body).to include('card-expired-coupons-list')
    end

    it 'not set, shows expired coupons' do
      site.setting.update(publisher_site: { hide_expired_coupons: nil })
      get :show, params: { slug: shop.slug }
      expect(response.body).to include('card-expired-coupons-list')
    end
  end

  describe "GET 'vote'" do
    it "returns http success" do
      get :vote, xhr: true, params: { id: shop.id, stars: 5 }
      expect(response.status).to eq 200
      expect(Vote.count).to eq 1
    end
  end
end
