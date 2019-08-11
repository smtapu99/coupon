describe Setting do
  it 'has a valid factory' do
    expect(FactoryGirl.build(:setting)).to be_valid
  end

  context 'updates RoutesChangedTimestamp.timestamp' do
    let!(:site) { create :site, hostname: 'test.host' }
    let!(:setting) { create :setting, site: site, routes: { campaign_sub_page: 'test' } }

    before do
      Rails.cache.write("#{site.hostname}_rcts", 1000, expires_in: 30.days)
    end

    def routes_timestamp(site)
      Rails.cache.read("#{site.hostname}_rcts")
    end

    it 'when routes_changed = true' do
      Setting.routes_changed = true

      setting.update(routes: { shop_campaign_page: '/shop-:shop_slug/:slug' })
      expect(routes_timestamp(site)).to_not eq(1000)
    end

    it 'not if routes_changed = false' do
      Setting.routes_changed = false
      setting.update(site_id: 2)
      expect(routes_timestamp(site)).to eq(1000)
    end
  end

  context 'routes' do
    before do
      Setting.routes_changed = true
    end

    context "succeeds if" do
      it ':application_root_dir is a correct directory' do
        expect(build(:setting, routes: { application_root_dir: '/test' })).to be_valid
      end

      it ':shop_campaign_page contains Shop Page url' do
        expect(build(:setting, routes: { shop_campaign_page: '/shop-:shop_slug/:slug', shop_show: '/shop-:slug' })).to be_valid
      end

      it ':campaign_sub_page contains Campaign Page url' do
        expect(build(:setting, routes: { campaign_sub_page: '/campaign-:parent_slug/:slug', campaign_page: '/campaign-:slug' })).to be_valid
      end
    end

    context 'fails if' do
      it ":application_root_dir is /" do
        expect(build(:setting, routes: { application_root_dir: '/' })).not_to be_valid
      end

      it ':campaign is at root like /:slug.' do
        expect(build(:setting, routes: { campaign_page: '/:slug' })).not_to be_valid
      end

      it ':campaign_sub_page is at root like /:parent_slug/:slug.' do
        expect(build(:setting, routes: { campaign_sub_page: '/:parent_slug/:slug' })).not_to be_valid
      end

      it ':shop_campaign_page does not contain Shop Page url' do
        expect(build(:setting, routes: { shop_campaign_page: '/shop-:shop_slug/:slug', shop_show: '/:slug' })).not_to be_valid
      end

      it ':campaign_sub_page does not contain Campaign Page url' do
        expect(build(:setting, routes: { campaign_sub_page: '/campaign-:parent_slug/:slug', campaign_page: '/:slug' })).not_to be_valid
      end
    end
  end

  context '.home_breadcrumb_name_needed?' do
    let!(:site) { create :site, hostname: 'test.host' }
    let!(:setting) { create :setting, site: site }

    it 'returns false unless application_root_dir present or application_root_dir = "/"' do
      setting.value[:routes] = OpenStruct.new({ application_root_dir: nil })
      expect(setting.home_breadcrumb_name_needed?).to eq(false)

      setting.value[:routes] = OpenStruct.new({ application_root_dir: '/' })
      expect(setting.home_breadcrumb_name_needed?).to eq(false)
    end

    it 'returns false if home_breadcrumb_name is set' do
      setting.value[:publisher_site] = OpenStruct.new({ home_breadcrumb_name: 'Vouchercodes' })
      expect(setting.home_breadcrumb_name_needed?).to eq(false)
    end

    it 'returns true otherwise' do
      setting.value[:routes] = OpenStruct.new({ application_root_dir: '/vouchercodes' })
      setting.value[:publisher_site] = OpenStruct.new({ home_breadcrumb_name: nil })
      expect(setting.home_breadcrumb_name_needed?).to eq(true)
    end
  end
end
