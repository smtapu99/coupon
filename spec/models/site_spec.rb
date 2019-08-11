describe Site, type: :model do
  let!(:site) { create :site, hostname: 'test.host' }

  it "has a valid factory" do
    expect(FactoryGirl.build(:site)).to be_valid
  end

  it 'has a valid API key' do
    expect(ApiKey.where(site_id: site.id)).to_not eq nil
  end

  context '::site_currency' do
    it 'returns the correct currencies' do
      expect(Site.site_currency('es-ES')).to eq('€')
      expect(Site.site_currency('it-IT')).to eq('€')
      expect(Site.site_currency('fr-FR')).to eq('€')
      expect(Site.site_currency('de-DE')).to eq('€')
      expect(Site.site_currency('ru-RU')).to eq('руб.')
      expect(Site.site_currency('pl-PL')).to eq('zł')
      expect(Site.site_currency('pt-BR')).to eq('R$')
      expect(Site.site_currency('en-GB')).to eq('£')
      I18n.locale = :en
      expect(Site.site_currency).to eq('$')
    end
  end

  context '::by_host' do
    it 'returns a single site by hostname' do
      expect(Site.by_host('test.host').first).to eq(site)
    end
  end

  context '::multisite_per_request' do
    let!(:multisite) { create :site, hostname: 'test.host', is_multisite: true, subdir_name: '/coupons' }
    let!(:request) { OpenStruct.new(original_url: 'http://test.host/coupons', host: 'test.host') }

    it 'returns a single multisite by request params' do
      expect(Site.multisite_per_request(request)).to eq(multisite)
    end
  end

  context '::host_to_file_name' do
    before { Site.current = site }
    it 'returns current sites hostname without www. and dots' do
      expect(Site::host_to_file_name).to eq('testhost')
    end
  end

  context '::root_campaigns' do
    let!(:root_campaign) { create :campaign, is_root_campaign: true, status: 'active' }
    let!(:other_root_campaign) { create :campaign, is_root_campaign: true, status: 'blocked' }

    it 'returns all root campaigns' do
      expect(site.root_campaigns.count).to eq(2)
    end
  end

  it 'has a valid API key' do
    expect(ApiKey.where(site_id: site.id)).to_not eq nil
  end

  context '.surrogate_key' do
    it 'returns a sanitized hostname' do
      expect(site.surrogate_key).to eq('testhost')
    end
  end

  context '.default_routes' do
    it 'returns hash of default routes' do
      expect(site.default_routes).to include(
        {
          contact_form: '/contact',
          report_form: '/report',
          partner_form: '/partner',
          shop_index: '/shops',
          category: '/categories',
          popular_coupons: '/popular-coupons',
          top_coupons: '/top-coupons',
          new_coupons: '/new-coupons',
          expiring_coupons: '/expiring-coupons',
          free_delivery_coupons: '/free-delivery-coupons',
          free_coupons: '/free-coupons',
          exclusive_coupons: '/exclusive-coupons',
          search_page: '/search',
          go_to_coupon: '/go-to-coupon/:id',
          category_show: '/category/:slug',
          subcategory_show: '/category/:parent_slug/:slug',
          campaign_sub_page: '/campaign/:parent_slug/:slug',
          campaign_page: '/campaign/:slug',
          shop_show: '/shop/:slug',
          shop_campaign_page: '/shop/:shop_slug/:slug',
          page_show: '/:slug.html',
        }
      )
    end
  end

  context '.id_and_name' do
    it 'returns id - name' do
      expect(site.id_and_name).to eq("#{site.id} - #{site.name}")
    end
  end

  context '.host_to_file_name' do
    before { site.update(hostname: 'www.test.host') }
    it 'returns hostname without www. and dots' do
      expect(site.host_to_file_name).to eq('testhost')
    end
  end

  context '.only_domain' do
    before { site.update(hostname: 'www.test.host') }
    it 'returns hostname without www.' do
      expect(site.only_domain).to eq('test.host')
    end
  end

  context '.timezone' do
    it 'returns Berlin by default' do
      site.time_zone = nil
      expect(site.timezone).to eq('Berlin')
    end

    it 'returns its countries timezone or Berlin' do
      site.update(time_zone: 'America/New_York')
      expect(site.timezone).to eq('America/New_York')
    end
  end

  context '.host_and_subdir_name' do
    context 'when is_multisite' do
      subject { build(:site, is_multisite: true, hostname: 'www.test.de', subdir_name: '/test').host_and_subdir_name }
      it { is_expected.to eq('www.test.de/test') }

      context 'and subdir_name doesnt contain /' do
        before { site.update subdir_name: 'test' }
        it { is_expected.to eq('www.test.de/test') }
      end
    end

    context 'when not is_multisite' do
      subject { build(:site, is_multisite: false, hostname: 'www.test.de', subdir_name: '/test').host_and_subdir_name }
      it { is_expected.to eq('www.test.de') }
    end
  end

  context 'updates RoutesChangedTimestamp.timestamp' do

    before do
      Rails.cache.write("#{site.hostname}_rcts", 1000, expires_in: 30.days)
    end

    def routes_timestamp(site)
      Rails.cache.read("#{site.hostname}_rcts")
    end

    it 'on update' do
      site.update(hostname: 'another.host')
      expect(routes_timestamp(site)).to_not eq(1000)
    end

    it 'not on update if hostname didnt change' do
      site.update(name: 'another title')
      expect(routes_timestamp(site)).to eq(1000)
    end

    it 'on create' do
      another_site = FactoryGirl.create(:site, hostname: 'another.host')
      expect(routes_timestamp(another_site)).to_not eq(1000)
    end
  end

  it 'creates an ImageSetting on create' do
    expect(site.image_setting).to eq(ImageSetting.last)
  end
end
