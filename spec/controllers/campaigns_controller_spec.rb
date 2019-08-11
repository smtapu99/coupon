describe CampaignsController do
  include ApplicationHelper

  let!(:site) { create :site, hostname: 'test.host' }
  let!(:setting) { create :setting_admin_rules, site: site }

  describe 'GET "show"' do
    let!(:shop) { create :shop }
    let!(:parent) { create :campaign }
    let!(:campaign) { create :campaign }

    before do
      @site = SiteFacade.new(site)
      default_url_options[:host] = @site.site.hostname
    end

    it '200 if campaign exists and active' do
      get :show, params: { slug: campaign.slug, parent_slug: campaign.parent_slug }
      expect(response.code).to eq '200'
    end

    it '404 if campaign doesnt exist ' do
      get :show, params: { slug: 'doesnt-exist' }
      expect(response.code).to eq '404'
    end

    context 'SEM' do
      it '404 if template DEFAULT but action "sem" requested' do
        campaign.update(template: 'default')
        get :sem, params: { slug: campaign.slug }
        expect(response.code).to eq '404'
      end

      it '404 if template SEM but action "show" requested' do
        campaign.update(template: 'sem')
        get :show, params: { slug: campaign.slug }
        expect(response.code).to eq '404'
      end
    end

    context 'when parent present' do

      context 'when campaign blocked' do
        before { campaign.update(parent: parent, status: 'blocked') }
        it do
          get :show, params: { slug: campaign.slug, parent_slug: campaign.parent_slug }
          expect(response).to redirect_to dynamic_campaign_url_for(parent)
        end
      end

      context 'when campaign gone' do
        before { campaign.update(parent: parent, status: 'gone') }
        it do
          get :show, params: { slug: campaign.slug, parent_slug: campaign.parent_slug }
          expect(response).to redirect_to dynamic_campaign_url_for(parent)
        end
      end

      context 'when parent blocked' do
        before { parent.update(status: 'blocked') }

        context 'when campaign active' do
          before { campaign.update(parent: parent, status: 'active') }
          it do
            get :show, params: { slug: campaign.slug, parent_slug: campaign.parent_slug }
            expect(response).to have_http_status(:not_found)
          end
        end

        context 'when campaign blocked' do
          before { campaign.update(parent: parent, status: 'blocked') }
          it do
            get :show, params: { slug: campaign.slug, parent_slug: campaign.parent_slug }
            expect(response).to redirect_to root_url
          end
        end

        context 'when campaign gone' do
          before { campaign.update(parent: parent, status: 'gone') }
          it do
            get :show, params: { slug: campaign.slug, parent_slug: campaign.parent_slug }
            expect(response).to have_http_status(:not_found)
          end
        end
      end
    end

    context 'when shop present' do
      context 'when campaign is blocked' do
        before { campaign.update(shop: shop, status: 'blocked') }
        it do
          get :show, params: { slug: campaign.slug, shop_slug: campaign.shop_slug }
          expect(response).to redirect_to dynamic_url_for('shops', 'show', slug: shop.slug)
        end
      end

      context 'when campaign is gone' do
        before { campaign.update(shop: shop, status: 'gone') }
        it do
          get :show, params: { slug: campaign.slug, shop_slug: campaign.shop_slug }
          expect(response).to redirect_to dynamic_url_for('shops', 'show', slug: shop.slug)
        end
      end

      context 'when shop is blocked' do
        before { shop.update(status: 'blocked') }

        context 'when campaign is active' do
          before { campaign.update(shop: shop, status: 'active') }

          context 'when shop has category' do
            let(:category) { create(:category, site_id: site.id)  }
            before { shop.shop_categories << category}
            it do
              get :show, params: { slug: campaign.slug, shop_slug: campaign.shop_slug }
              expect(response).to redirect_to(dynamic_url_for('category', 'show', slug: category.slug, parent_slug: category.parent_slug))
            end
          end
        end

        context 'when campaign is blocked' do
          before { campaign.update(shop: shop, status: 'blocked') }
          it do
            get :show, params: { slug: campaign.slug, shop_slug: campaign.shop_slug }
            expect(response).to redirect_to root_url
          end

          context 'when shop has category' do
            let(:category) { create(:category, site_id: site.id)  }
            before { shop.shop_categories << category}
            it do
              get :show, params: { slug: campaign.slug, shop_slug: campaign.shop_slug }
              expect(response).to redirect_to(dynamic_url_for('category', 'show', slug: category.slug, parent_slug: category.parent_slug))
            end
          end
        end

        context 'when campaign is gone' do
          before { campaign.update(shop: shop, status: 'gone') }
          it do
            get :show, params: { slug: campaign.slug, shop_slug: campaign.shop_slug }
            expect(response).to have_http_status(:not_found)
          end
        end
      end
    end

    context 'if is_root_campaign?' do
      before { campaign.update(is_root_campaign: true) }

      it 'matches' do
        get :show, params: { slug: campaign.slug }
        expect(response.code).to eq '200'
      end
    end

    context 'if is_root_campaign? with parent_id' do
      let!(:sub_campaign) { create :campaign, is_root_campaign: true, parent_id: campaign.id }

      it 'matches' do
        get :show, params: { slug: campaign.slug, parent_slug: campaign.parent_slug}
        expect(response.code).to eq '200'
      end
    end
  end
end
