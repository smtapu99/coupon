describe Admin::AwinMigrationController do
  let!(:site) { create :site, hostname: 'test.host' }
  let!(:shop) { create :shop, site: site, prefered_affiliate_network_id: AwinMigration::ZANOX_ID }
  let!(:zanox_coupon) do
    create :coupon,
      shop: shop,
      site: site,
      url: 'http://init.url',
      affiliate_network_id: AwinMigration::ZANOX_ID,
      end_date: Time.zone.now + 2.days
  end

  login_admin

  before do
    Site.current = site
  end

  describe 'GET awin' do
    it 'assigns @migration, @shops and renders awin template' do
      get :awin
      expect(assigns(:migration)).to be_a(AwinMigration)
      expect(assigns(:shops)).to eq([shop].collect { |i| [i.title_and_site_name, i.id] })
      expect(response).to render_template('awin')
    end
  end

  describe 'POST migrate_awin' do
    describe 'validates false' do
      it 'if shop_id is missing' do
        post :migrate_awin, params: { awin_migration: { shop_id: nil } }
        expect(assigns(:migration)).to_not be_valid
      end

      it 'if clickout_url is missing' do
        post :migrate_awin, params: { awin_migration: { shop_id: shop.id } }
        expect(assigns(:migration)).to_not be_valid
      end

      it 'if clickout_url isnt an url' do
        post :migrate_awin, params: { awin_migration: { shop_id: shop.id, clickout_url: 'http:wrong_url' } }
        expect(assigns(:migration)).to_not be_valid
        expect(assigns(:count)).to be_nil
      end
    end

    describe 'step 1' do
      it 'assigns @count' do
        post :migrate_awin, params: { awin_migration: { shop_id: shop.id, clickout_url: 'http://new.url' } }
        expect(assigns(:count)).to eq(1)
        expect(response).to render_template('awin')
      end
    end

    describe 'step 2' do

      context 'when change_to_awin == 1' do

        it 'updates the coupon_url of non expired active coupons' do
          post :migrate_awin, params: { awin_migration: { shop_id: shop.id, clickout_url: 'http://new.url', run: true } }
          expect(zanox_coupon.reload.url).to eq('http://new.url')
          expect(zanox_coupon.reload.affiliate_network_id).to eq(AwinMigration::ZANOX_ID)
          expect(response.code).to eq("302")
        end

        it 'does not update the coupon_url of non expired inactive coupons' do
          zanox_coupon.update_attribute(:status, 'blocked')
          post :migrate_awin, params: { awin_migration: { shop_id: shop.id, clickout_url: 'http://new.url', run: true } }
          expect(zanox_coupon.reload.url).to_not eq('http://new.url')
          expect(zanox_coupon.reload.affiliate_network_id).to eq(AwinMigration::ZANOX_ID)
          expect(response.code).to eq("302")
        end

        it 'does not update affiliate_newtwork_id of shop and coupon if change_to_awin = 0' do
          post :migrate_awin, params: { awin_migration: { shop_id: shop.id, clickout_url: 'http://new.url', run: true } }
          expect(zanox_coupon.reload.url).to eq('http://new.url')
          expect(zanox_coupon.reload.affiliate_network_id).to eq(AwinMigration::ZANOX_ID)
          expect(shop.reload.prefered_affiliate_network_id).to eq(AwinMigration::ZANOX_ID)
          expect(response.code).to eq("302")
        end

      end

      context 'when change_to_awin == 0' do

        it 'updates affiliate_newtwork_id of shop and coupon' do
          post :migrate_awin, params: { awin_migration: { shop_id: shop.id, clickout_url: 'http://new.url', run: true, change_to_awin: '1' } }
          expect(zanox_coupon.reload.url).to eq('http://new.url')
          expect(zanox_coupon.reload.affiliate_network_id).to eq(AwinMigration::AWIN_ID)
          expect(shop.reload.prefered_affiliate_network_id).to eq(AwinMigration::AWIN_ID)
          expect(response.code).to eq("302")
        end

        it 'does not update expired zanox coupons' do
          zanox_coupon.update_attribute(:end_date, Time.zone.now - 2.days)
          post :migrate_awin, params: { awin_migration: { shop_id: shop.id, clickout_url: 'http://new.url', run: true, change_to_awin: '1' } }

          expect(zanox_coupon.reload.url).to eq('http://init.url')
          expect(zanox_coupon.reload.affiliate_network_id).to_not eq(AwinMigration::AWIN_ID)
          expect(response.code).to eq("302")
        end
      end
    end
  end
end
