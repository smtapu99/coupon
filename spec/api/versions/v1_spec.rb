def to_rabl(entity, view, view_path = 'app/api/views/v1')
  Rabl.render(entity, view, { format: :json, view_path: Rails.root.join(view_path) })
end

def authorize_and_get_token
  user
  post "/api/auth/login", params: { password: user.password, login: user.email }
  body = JSON.parse(response.body)
  @token = body["token"]
end

describe Api do

  include ApplicationHelper

  let!(:site) { create(:site, hostname: 'www.example.com') }
  let(:authorization_header) { { 'Authorization' => 'Bearer ' + site.api_key.access_token } }

  context "when depending on auth token" do
    let(:user) { create(:super_admin) }

    before do
      authorize_and_get_token
    end

    it "is possible to get access token" do
      expect(@token.length).to eq(32)
    end
  end

  context "when depending on GAE cron header" do

    context "Cron" do

      describe "GET /api/v1/cron/active_coupons_count" do

        context "without cron header" do
          it "expected to be forbidden" do
            get "/api/v1/cron/active_coupons_count"
            expect(response.code).to eq "403"
          end
        end

        context "with cron header" do
          it "expected to be OK" do
            get "/api/v1/cron/active_coupons_count", headers: { 'X-Appengine-Cron' => 'true' }
            expect(response.code).to eq "200"
          end
        end
      end
    end
  end

  context 'Snippets' do

    before { @site = SiteFacade.new(site) }

    def categories_json(categories)
      categories.map do |cat|
        {
          id: cat.id,
          slug: cat.slug,
          name: cat.name,
          anchor_text: cat.try(:html_document).try(:dynamic_h1, @site.coupons_by_categories(cat.id)),
          url: dynamic_url_for('categories', 'show', slug: cat.slug, parent_slug: cat.parent_slug, protocol: @site.site.protocol, only_path: false),
        }
      end
    end

    def shops_json(shops)
      [*shops].map do |shop|
        coupons = @site.coupons_by_shops(shop.id, false).order_by_shop_list_priority
        best_offer = coupons.first

        {
          id: shop.id,
          name: shop.title,
          anchor_text: shop.try(:html_document).try(:dynamic_h1, coupons),
          url: dynamic_url_for('shops', 'show', slug: shop.slug, protocol: @site.site.protocol, only_path: false),
          logo: shop.logo_url('_200x200'),
          image: shop.header_image_url('_0x120'),
          best_offer_id: best_offer.try(:id),
          best_offer_text: best_offer.try(:title),
          category: shop.api_category_slug
        }
      end.to_json
    end

    context 'Categories' do

      let!(:categories) { create_list :category, 10, site: site }

      it 'shows 10 active categories' do
        get "/api/v1/snippet/categories", headers: authorization_header
        expect(JSON.parse(response.body).count).to eq(10)
      end

      it 'takes limit param' do
        get "/api/v1/snippet/categories", params: { limit: 5 }, headers: authorization_header
        expect(JSON.parse(response.body).count).to eq(5)
      end

      it 'returns surrogate_key header' do
        get "/api/v1/snippet/categories", headers: authorization_header
        expect(response.headers["Surrogate-Key"]).not_to be_empty
      end

      context 'surrogate_control' do
        context 'with default value' do
          it do
            get "/api/v1/snippet/categories", headers: authorization_header
            expect(response.headers["Surrogate-Control"]).to eq('max-age=3600')
          end
        end

        context 'with custom time value' do
          subject { Resources::V1::Snippets }
          before do
            subject.after do
              set_surrogate_control_header(7200)
            end
          end

          after { subject.after { set_surrogate_control_header } }

          it do
            get "/api/v1/snippet/categories", headers: authorization_header
            expect(response.headers["Surrogate-Control"]).to eq('max-age=7200')
          end
        end
      end
    end

    context 'Coupons' do

      let!(:coupons) { create_list :coupon, 10, site: site, is_top: 1 }
      let!(:shops) { create_list :shop, 10, site: site }

      before do
        # redistribute the coupons 1 per shop
        shops = Shop.all.to_a
        Coupon.all.each_with_index do |coupon, index|
          coupon.update(shop_id: shops[index].id)
        end
      end

      it 'returns only one per shop' do
        Coupon.update_all(shop_id: Shop.first.id)
        get "/api/v1/snippet/coupons", headers: authorization_header
        expect(JSON.parse(response.body).count).to eq(1)
      end

      it 'returns top coupons' do
        get "/api/v1/snippet/coupons", headers: authorization_header
        expect(JSON.parse(response.body).count).to eq(10)
      end

      it 'shows only active coupons' do
        Coupon.last.update(status: 'blocked')
        get "/api/v1/snippet/coupons", headers: authorization_header
        expect(JSON.parse(response.body).count).to eq(9)
      end

      it 'takes limit param' do
        get "/api/v1/snippet/coupons", params: { limit: 5 }, headers: authorization_header
        expect(JSON.parse(response.body).count).to eq(5)
      end

      it 'returns surrogate_key header' do
        get "/api/v1/snippet/coupons", headers: authorization_header
        expect(response.headers["Surrogate-Key"]).not_to be_empty
      end

      context 'surrogate_control' do
        context 'with default value' do
          it do
            get "/api/v1/snippet/coupons", headers: authorization_header
            expect(response.headers["Surrogate-Control"]).to eq('max-age=3600')
          end
        end

        context 'with custom time value' do
          subject { Resources::V1::Snippets }
          before do
            subject.after do
              set_surrogate_control_header(7200)
            end
          end

          after { subject.after { set_surrogate_control_header } }

          it do
            get "/api/v1/snippet/coupons", headers: authorization_header
            expect(response.headers["Surrogate-Control"]).to eq('max-age=7200')
          end
        end
      end

      context 'with "categories"' do
        let!(:category1) { create :category, slug: 'my-category-1' }
        let!(:category2) { create :category, slug: 'my-category-2' }
        let!(:coupons_ids) { [coupons.first.id, coupons.second.id, coupons.last.id] }
        let!(:top_coupon) { coupons.first.update(categories: [category1], is_top: 1, is_exclusive: false); coupons.first }
        let!(:exclusive_coupon) { coupons.last.update(categories: [category2], is_top: false, is_exclusive: 1); coupons.last }
        let!(:other_coupon) { coupons.second.update(categories: [category1], is_top: false, is_exclusive: false); coupons.second }

        it 'returns coupons from that categories' do
          get "/api/v1/snippet/coupons", params: { categories: 'my-category-1,my-category-2' }, headers: authorization_header
          expect(JSON.parse(response.body).count).to eq(3)
          expect(JSON.parse(response.body).first['id']).to eq(exclusive_coupon.id)
          expect(JSON.parse(response.body).second['id']).to eq(top_coupon.id)
          expect(JSON.parse(response.body).last['id']).to eq(other_coupon.id)
        end
      end

      context 'with "campaigns"' do
        let!(:campaign0) { create :campaign, slug: 'my-campaign-1' }
        let!(:campaign1) { create :campaign, slug: 'my-campaign-2' }

        it 'returns coupons from that campaigns' do
          coupons.take(2).each_with_index do |coupon, index|
            coupon.origin_coupon_form = true
            coupon.campaigns = [send("campaign#{index}")]
          end

          get "/api/v1/snippet/coupons", params: { campaigns: 'my-campaign-1,my-campaign-2' }, headers: authorization_header
          expect(JSON.parse(response.body).count).to eq(2)
        end
      end

      context 'with "campaigns" && "categories"' do
        it 'returns 400 header' do
          get "/api/v1/snippet/coupons", params: { campaigns: 'test', categories: 'test' }, headers: authorization_header
          expect(response.code).to eq("400")
        end
      end
    end

    context 'Top Shops' do
      let!(:shops) { create_list :shop, 2, site: site, active_coupons_count: 1 }
      let!(:setting) { create :setting, site: site, publisher_site: { featured_shop_ids: [shops.first.id, shops.last.id] }}

      it 'shows featured shops as per setting' do
        get "/api/v1/snippet/top-shops", headers: authorization_header
        expect(JSON.parse(response.body).first['id']).to eq(Shop.first.id)
        expect(JSON.parse(response.body).last['id']).to eq(Shop.last.id)
      end

      it 'shows featured shops in the correct order' do
        setting.update(publisher_site: { featured_shop_ids: [shops.last.id, shops.first.id] })
        get "/api/v1/snippet/top-shops", headers: authorization_header
        expect(JSON.parse(response.body).first['id']).to eq(Shop.last.id)
        expect(JSON.parse(response.body).last['id']).to eq(Shop.first.id)
      end

      it 'returns surrogate_key header' do
        get "/api/v1/snippet/top-shops", headers: authorization_header
        expect(response.headers["Surrogate-Key"]).not_to be_empty
      end

      context 'surrogate_control' do
        context 'with default value' do
          it do
            get "/api/v1/snippet/top-shops", headers: authorization_header
            expect(response.headers["Surrogate-Control"]).to eq('max-age=3600')
          end
        end

        context 'with custom time value' do
          subject { Resources::V1::Snippets }
          before do
            subject.after do
              set_surrogate_control_header(7200)
            end
          end

          after { subject.after { set_surrogate_control_header } }

          it do
            get "/api/v1/snippet/top-shops", headers: authorization_header
            expect(response.headers["Surrogate-Control"]).to eq('max-age=7200')
          end
        end
      end
    end

    context 'Shops' do
      let!(:shops) { create_list :shop, 10, site: site, active_coupons_count: 1 }

      before do
        Shop.all.each_with_index do |shop, i|
          shop.update(priority_score: i)
          create :coupon, shop: shop, site: site
        end
      end

      it 'shows 10 active shops with active coupons ordered by priority_score' do
        get "/api/v1/snippet/shops", headers: authorization_header
        expect(JSON.parse(response.body).count).to eq(10)
      end

      context 'utm_source' do
        context 'when site.id == 76' do
          let!(:site) { create :site, id: 76, hostname: 'www.another-site.com' }

          context 'when referer includes pagesix' do
            it 'equals pagesixsnippet' do
              get "/api/v1/snippet/shops", headers: authorization_header.merge('Referer' => 'http://pagesix.com')
              expect(JSON.parse(response.body).first['url']).to include('utm_source=pagesixsnippet')
            end
          end

          context 'when referer doesnt include pagesix' do
            it 'equals nypostsnippet' do
              get "/api/v1/snippet/shops", headers: authorization_header.merge('Referer' => 'http://nyp.com')
              expect(JSON.parse(response.body).first['url']).to include('utm_source=nypostsnippet')
            end
          end
        end

        context 'when site.id != 76' do
          it 'is not included' do
            get "/api/v1/snippet/shops", headers: authorization_header.merge('Referer' => 'http://nyp.com')
            expect(JSON.parse(response.body).first['url']).to_not include('utm_source')
          end
        end
      end

      it 'takes limit param' do
        get "/api/v1/snippet/shops", params: { limit: 5 }, headers: authorization_header
        expect(JSON.parse(response.body).count).to eq(5)
      end

      it 'orders by priority_score' do
        get "/api/v1/snippet/shops", headers: authorization_header
        expect(JSON.parse(response.body)[0]).to eq(JSON.parse(shops_json(Shop.order(priority_score: :desc).first)).first)
      end

      it 'doesnt show inactive shops' do
        Shop.last.update(status: 'blocked')
        get "/api/v1/snippet/shops", headers: authorization_header
        expect(JSON.parse(response.body).count).to eq(9)
      end

      it 'returns surrogate_key header' do
        get "/api/v1/snippet/shops", headers: authorization_header
        expect(response.headers["Surrogate-Key"]).not_to be_empty
      end

      context 'surrogate_control' do
        context 'with default value' do
          it do
            get "/api/v1/snippet/shops", headers: authorization_header
            expect(response.headers["Surrogate-Control"]).to eq('max-age=3600')
          end
        end

        context 'with custom time value' do
          subject { Resources::V1::Snippets }
          before do
            subject.after do
              set_surrogate_control_header(7200)
            end
          end

          after { subject.after { set_surrogate_control_header } }

          it do
            get "/api/v1/snippet/shops", headers: authorization_header
            expect(response.headers["Surrogate-Control"]).to eq('max-age=7200')
          end
        end
      end

      context 'with tags' do
        before { Site.current = site }

        # 1 tag with category 1
        let!(:shops1) { create_list :shop, 3, site: site }
        let!(:category1) { create :category, site: site, id: 1000, related_shops: shops1 }
        let!(:tag1) { create :tag, site: site, category: category1 }

        # 2 tags with category 2
        let!(:shops2) { create_list :shop, 5, site: site }
        let!(:category2) { create :category, site: site, id: 1001, related_shops: shops2 }
        let!(:tag2) { create :tag, site: site, category: category2 }
        let!(:tag3) { create :tag, site: site, category: category2 }

        # 1 tag without any category
        let!(:tag4) { create :tag, site: site }

        def request
          get "/api/v1/snippet/shops", params: { tags: Tag.all.pluck(:word).join(',') }, headers: authorization_header
        end

        it 'returns shops from categories with that the single most matched tag' do
          request
          expect(JSON.parse(response.body).map{ |i| i['id'] }).to match_array(shops2.map(&:id))
        end

        it 'increments tag api_hits' do
          request
          expect(tag1.reload.api_hits).to eq(1)
        end

        context 'when tag doesnt exist' do
          it 'creates tag' do
            get "/api/v1/snippet/shops", params: { tags: 'doesnt-exist' }, headers: authorization_header
            expect(Tag.where(word: 'doesnt-exist', site: site).any?).to eq(true)
          end
        end

        context 'when tag is blacklisted' do
          before { tag1.update(is_blacklisted: true) }
          it 'returns no shops' do
            request
            expect(JSON.parse(response.body).count).to eq(0)
          end
        end

        context 'when equal matches' do
            before { tag3.destroy }
          it 'returns all shops from matching tags' do
            request
            expect(JSON.parse(response.body).map {|i| i['id']}).to match_array(shops1.map(&:id) + shops2.map(&:id))
          end
        end

        context 'when no matches' do
          before { Tag.update_all(category_id: nil) }
          it 'returns no shops' do
            request
            expect(JSON.parse(response.body).count).to eq(0)
          end
        end
      end

      context 'with categories' do
        let!(:tier_1_shops) do
          Shop.order(id: :asc).limit(5).update(tier_group: 1)
          Shop.order(id: :asc).limit(5)
        end

        let!(:tier_2_shops) do
          Shop.order(id: :desc).limit(5).update(tier_group: 2)
          Shop.order(id: :desc).limit(5)
        end

        before do
          create_list :category, 2, site: site

          Category.first.update(related_tier_1_shops: tier_1_shops)
          Category.last.update(related_tier_2_shops: tier_2_shops)
        end

        it 'shows only shops that are assigned to the category' do
          get "/api/v1/snippet/shops", params: { categories: Category.first.slug }, headers: authorization_header
          expect(JSON.parse(response.body).count).to eq(5)

          get "/api/v1/snippet/shops", params: { categories: Category.all.map(&:slug).join(', ') }, headers: authorization_header
          expect(JSON.parse(response.body).count).to eq(10)
        end

        it 'returns shop with limit 1' do
          get "/api/v1/snippet/shops", params: { categories: Category.first.slug, limit: 1 }, headers: authorization_header
          expect(JSON.parse(response.body).count).to eq(1)
        end

        it 'returns enough tier 1 shops' do
          Category.first.update(related_tier_2_shops: tier_2_shops)
          get "/api/v1/snippet/shops", params: { categories: Category.first.slug, limit: 3 }, headers: authorization_header
          expect(JSON.parse(response.body).count).to eq(3)
          expect(JSON.parse(response.body).map { |item| item['id'] }).to_not include(*tier_2_shops.map(&:id))
        end
      end
    end
  end

  context 'Shops' do

    def shop_json(shop)
      {
        'id' => shop.id,
        'name' => shop.title
      }
    end

    let!(:shops) { create_list :shop, 20, site: site }

    before { @site = SiteFacade.new(site) }

    it '/api/v1/shops' do
      get '/api/v1/shops', headers: authorization_header

      expect(JSON.parse(response.body)['limit']).to eq(50)
      expect(JSON.parse(response.body)['offset']).to eq(0)
    end

    it '/api/v1/shops/:id' do
      shop = @site.shops.first
      get "/api/v1/shops/#{shop.id}", headers: authorization_header
      expect(JSON.parse(response.body)).to include(shop_json(shop))
    end

    it 'returns shops and meta information' do
      shops = @site.shops.order_by_priority.limit(10).offset(10)
      get '/api/v1/shops', params: { limit: 10, offset: 10 }, headers: authorization_header

      expect(JSON.parse(response.body)['shops']).to include(shop_json(shops.last))
      expect(JSON.parse(response.body)['limit']).to eq(10)
      expect(JSON.parse(response.body)['offset']).to eq(10)
      expect(JSON.parse(response.body)['total']).to eq(20)
      expect(JSON.parse(response.body)['max_offset']).to eq(10)
    end
  end

  context 'Coupons' do

    def coupon_json(coupon)
      {
        'id' => coupon.id,
        'shop_id' => coupon.shop_id,
        # 'category_ids' => coupon.category_ids,
        'title' => coupon.title,
        'description' => coupon.description,
        'savings' => coupon.savings_in_string(false),
        'type' => coupon.coupon_type,
        'code' => coupon.code,
        'use_uniq_codes' => coupon.use_uniq_codes,
        'info_fields' => coupon.info_fields_hash,
        'logo' => coupon.coupon_or_shop_logo,
        'image' => coupon.widget_header_image_url('_0x120'),
        'clickout_url' => "https://#{@site.site.hostname}/api-clickout/#{coupon.id}",
        'start_date' => coupon.start_date.iso8601,
        'end_date' => coupon.end_date.iso8601,
      }
    end

    let!(:coupons) { create_list :coupon, 20, site: site }
    let(:shop) { create :shop, site: site }

    before { @site = SiteFacade.new(site) }

    it 'uses defaults' do
      get '/api/v1/coupons', headers: authorization_header

      expect(JSON.parse(response.body)['limit']).to eq(50)
      expect(JSON.parse(response.body)['offset']).to eq(0)
    end

    it '/api/v1/coupons' do
      coupons = @site.coupons.limit(10).offset(10)
      get '/api/v1/coupons', params: { limit: 10, offset: 10 }, headers: authorization_header

      expect(JSON.parse(response.body)['coupons']).to include(coupon_json(coupons.last))
      expect(JSON.parse(response.body)['limit']).to eq(10)
      expect(JSON.parse(response.body)['offset']).to eq(10)
      expect(JSON.parse(response.body)['total']).to eq(20)
      expect(JSON.parse(response.body)['max_offset']).to eq(10)
    end

    it '/api/v1/coupons/:id' do
      coupon = @site.coupons.first
      get "/api/v1/coupons/#{coupon.id}", headers: authorization_header
      expect(JSON.parse(response.body)).to include(coupon_json(coupon))
    end

    context 'with shop_ids' do
      let(:shop) { create :shop, site: site }
      let(:other_shop) { create :shop, site: site }

      before do
        coupons.first(5).map { |c| c.update(shop_id: shop.id) }
        coupons.last(5).map { |c| c.update(shop_id: other_shop.id) }
      end

      it 'returns coupons' do
        coupons = @site.coupons_by_shops([shop.id, other_shop.id], false).order_by_shop_list_priority
        get '/api/v1/coupons', params: { shop_ids: "#{shop.id}, #{other_shop.id}" }, headers: authorization_header

        expect(JSON.parse(response.body)['coupons']).to include(coupon_json(coupons.first))
        expect(JSON.parse(response.body)['coupons'].count).to eq(10)
        expect(JSON.parse(response.body)['total']).to eq(10)
        expect(JSON.parse(response.body)['max_offset']).to eq(0)
      end
    end

    context 'with category_ids' do
      let(:category) { create :category, site: site }
      let(:other_category) { create :category, site: site }

      before do
        coupons.first(5).map { |c| c.update(category_ids: [category.id]) }
        coupons.last(5).map { |c| c.update(category_ids: [other_category.id]) }
      end

      it 'returns coupons' do
        coupons =  @site.coupons_by_categories([category.id, other_category.id])
        get '/api/v1/coupons', params: { category_ids: "#{category.id}, #{other_category.id}" }, headers: authorization_header

        expect(JSON.parse(response.body)['coupons']).to include(coupon_json(coupons.first))
        expect(JSON.parse(response.body)['coupons'].count).to eq(10)
        expect(JSON.parse(response.body)['total']).to eq(10)
        expect(JSON.parse(response.body)['max_offset']).to eq(0)
      end
    end
  end
end


