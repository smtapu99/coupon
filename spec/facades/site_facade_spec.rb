describe SiteFacade do
  let!(:site) { create :site, hostname: 'test.host' }
  let(:facade) { SiteFacade.new(site) }

  describe '.popular_and_related_shops' do
    let!(:category) { create :category, site: site, main_category: 1 }
    let!(:shop) { create :shop, site: site, tier_group: 1, shop_categories: [category] }

    subject { facade.popular_and_related_shops(shop, category) }

    context 'when no shops exist' do
      it { is_expected.to eq({ popular: [], related: [] })}
    end

    context 'when popular_shops exist' do
      let!(:shops) { create_list :shop, 69, site: site, tier_group: 1, shop_categories: [category] }
      before { category.update(shops_by_shop_category: Shop.all) }
      subject { facade.popular_and_related_shops(shop, category)[:popular].map(&:id).size }
      it { is_expected.to eq(5) }
    end

    context 'when related_shops exist' do
      let!(:shops) { create_list :shop, 69, site: site, tier_group: 2, shop_categories: [category] }
      let!(:other_shops) { create_list :shop, 5, site: site, tier_group: 3, shop_categories: [category] }

      before do
        shop.update(tier_group: 2)
        category.update(shops_by_shop_category: Shop.all)
      end

      subject { facade.popular_and_related_shops(shop, category)[:related].map(&:id).size }
      it { is_expected.to eq((Shop.all.size * 0.1).ceil + 5) }
    end
  end

  describe '.campaign_coupons' do
    let!(:campaign) { create :campaign, site: site }
    let!(:coupons) { create_list :coupon, 2 }

    before do
      coupons.first.update(is_hidden: true)

      coupons.each do |coupon|
        coupon.origin_coupon_form = true
        coupon.campaigns << campaign
      end
    end

    it 'without priority_coupon_ids' do
      expect(facade.campaign_coupons(campaign)).to include(coupons.last)
    end

    it 'with priority_coupon_ids' do
      campaign.update(priority_coupon_ids: coupons.first.id)
      expect(facade.campaign_coupons(campaign)).to include(coupons.first, coupons.last)
    end

    it 'shows only active coupons' do
      Coupon.all.update(status: 'blocked')
      expect(facade.campaign_coupons(campaign).count).to eq(0)
    end
  end

  describe '.campaigns_for_sitemap' do
    subject { facade.campaigns_for_sitemap }

    context 'when campaign is active' do
      let!(:campaign) { create :campaign, status: :active }
      it { is_expected.to eq [campaign] }
    end

    context 'when campaign is blocked' do
      let!(:campaign) { create :campaign, status: :blocked }
      it { is_expected.to eq [] }
    end

    context 'when campaign is gone' do
      let!(:campaign) { create :campaign, status: :gone }
      it { is_expected.to eq [] }
    end
  end

  context 'menu' do
    let(:shop) { create :shop, site: site }
    let(:category) { create :category, site: site }
    let(:campaign) { create :campaign, site: site }

    before { Site.current = site }

    context 'nav_categories' do
      let!(:setting) { create :setting, menu: { navigation_category_ids: [category.id] } }
      subject { facade.nav_categories }
      it { is_expected.to include(category) }
    end

    context 'nav_campaigns' do
      let!(:setting) { create :setting, menu: { main_campaign_ids: [campaign.id] } }
      subject { facade.nav_campaigns }
      it { is_expected.to include(campaign) }
    end

    context 'nav_main_shops' do
      let!(:setting) { create :setting, menu: { main_shop_ids: [shop.id] } }
      subject { facade.nav_main_shops }
      it { is_expected.to include(shop) }
    end

    context 'nav_shops' do
      let!(:setting) { create :setting, menu: { navigation_shop_ids: [shop.id] } }
      subject { facade.nav_shops }
      it { is_expected.to include(shop) }
    end

    context 'footer_campaigns' do
      let!(:setting) { create :setting, menu: { footer_campaign_ids: [campaign.id] } }
      subject { facade.footer_campaigns }
      it { is_expected.to include(campaign) }
    end

    context 'footer_shops' do
      let!(:setting) { create :setting, menu: { footer_shop_ids: [shop.id] } }
      subject { facade.footer_shops }
      it { is_expected.to include(shop) }
    end
  end

  describe '.coupon' do
    let!(:shop) { create :shop, status: 'active' }
    let!(:coupon) { create :coupon, site: site, shop: shop }

    it 'returns the correct coupon if active' do
      coupon.update_attributes(status: 'active')

      expect(facade.coupon(coupon.id)).to eq coupon
    end

    it 'doesnt return blocked coupons' do
      coupon.update_attributes(status: 'blocked')

      expect(facade.coupon(coupon.id)).to be_nil
    end

    it 'doesnt return coupons from blocked shops' do
      coupon.update_attributes(status: 'active')
      shop.update_attributes(status: 'blocked')

      expect(facade.coupon(coupon.id)).to be_nil
    end

    it 'doesnt return coupons from gone shops' do
      coupon.update_attributes(status: 'active')
      shop.update_attributes(status: 'gone')

      expect(facade.coupon(coupon.id)).to be_nil
    end
  end

  describe '.image_setting' do
    it 'returns image_setting of site' do
      expect(facade.image_setting).to eq(ImageSetting.where(site_id: site.id).first)
    end
  end
end
