describe CouponsController do
  include RSpecHtmlMatchers
  include ApplicationHelper

  let!(:site) { create :site, hostname: 'test.host' }

  context "GET 'index'" do
    context 'shows correct robots meta tag' do
      render_views

      it 'when dynamic pages setting is blank' do
        create(:setting_admin_rules, admin_rules: { dynamic_pages: nil })
        get :index, params: { type: 'top' }
        expect(response.body).to have_tag('meta', with: { name: 'robots', content: 'noindex, nofollow'})
      end

      it 'when dynamic pages setting is noindex' do
        create(:setting_admin_rules, admin_rules: { dynamic_pages: 'noindex' })
        get :index, params: { type: 'top' }
        expect(response.body).to have_tag('meta', with: { name: 'robots', content: 'noindex, nofollow'})
      end

      context 'when dynamic_pages setting is index_plus_canonical' do
        it 'and paginate_categories is true' do
          create(:setting_admin_rules, admin_rules: { dynamic_pages: 'index_plus_canonical' }, publisher_site: { paginate_categories: 1 })
          get :index, params: { type: 'top' }
          expect(response.body).to have_tag('meta', with: { name: 'robots', content: 'noindex, nofollow'})
        end

        it 'and paginate_categories is false' do
          create(:setting_admin_rules, admin_rules: { dynamic_pages: 'index_plus_canonical' }, publisher_site: { paginate_categories: 0 })
          get :index, params: { type: 'top' }
          expect(response.body).to have_tag('meta', with: { name: 'robots', content: 'index, follow'})
        end
      end
    end

    context 'with paginate_categories' do
      let!(:setting) { create :setting_site, site: site }
      let!(:coupons) { create_list :coupon, 40, site: site, is_top: true }

      it 'true, it shows pagination' do
        get :index, params: { type: 'top' }
        expect(assigns(:coupons).size).to eq(20)
        expect(assigns(:coupons).respond_to?(:total_pages)).to eq(true)
      end

      it 'false, it hides pagination and shows 25 coupons' do
        setting.publisher_site.paginate_categories = 0
        setting.save
        get :index, params: { type: 'top' }
        expect(assigns(:coupons).size).to eq(25)
        expect(assigns(:coupons).respond_to?(:total_pages)).to eq(false)
      end
    end
  end

  context 'GET api-clickout/:id' do
    let!(:coupon) { create :coupon, site: site, url: 'http://url.de?pctracking' }

    before do
      get :api_clickout, params: { id: coupon.id }
    end

    it 'assigns coupon and redirect_url with replaced pctracking' do
      expect(assigns(:coupon)).to eq(coupon)
      expect(assigns(:redirect_url)).to eq('http://url.de?' + TrackingClick.last.uniqid)
    end

    it 'increments coupons.clicks' do
      expect(Coupon.last.clicks).to eq(1)
    end

    it 'creates a tracking_click' do
      expect(TrackingClick.all.count).to eq(1)
    end
  end

  context 'GET clickout/:id' do
    let!(:coupon) { create :coupon, site: site, url: 'http://url.de?pctracking' }

    before do
      get :clickout, params: { id: coupon.id }
    end

    it 'assigns coupon and redirect_url with replaced pctracking' do
      expect(assigns(:coupon)).to eq(coupon)
      expect(assigns(:redirect_url)).to eq('http://url.de?' + TrackingClick.last.uniqid)
    end

    it 'increments coupons.clicks' do
      expect(Coupon.last.clicks).to eq(1)
    end

    it 'creates a tracking_click' do
      expect(TrackingClick.all.count).to eq(1)
    end

    it '404 unless coupon.active?' do
      coupon.update(status: 'blocked')
      get :clickout, params: { id: coupon.id }

      expect(response).to have_http_status(:not_found)
    end

    it 'redirects to shop' do
      coupon.update(end_date: 1.minute.ago)
      get :clickout, params: { id: coupon.id }

      expect(response).to redirect_to(dynamic_url_for('shops', 'show', slug: coupon.shop_slug, expired: coupon.id))
    end

    context 'when shop.is_direct_clickout?' do
      before { coupon.shop.update(is_direct_clickout: true) }

      it 'redirects 307 to url with SubID replaced' do
        get :clickout, params: { id: coupon.id }
        expect(response).to have_http_status(:temporary_redirect)
        expect(response).to redirect_to('http://url.de?' + TrackingClick.last.uniqid)
      end
    end
  end

  context 'GET vote' do
    let!(:coupon) { create :coupon, site: site }

    it 'type=positive increments coupons.positive_votes' do
      get :vote, params: { id: coupon.id, type: 'positive' }, xhr: true
      expect(coupon.reload.positive_votes).to eq(1)
    end

    it 'type=negative increments coupons.negative_votes' do
      get :vote, params: { id: coupon.id, type: 'negative' }, xhr: true
      expect(coupon.reload.negative_votes).to eq(1)
    end
  end
end
