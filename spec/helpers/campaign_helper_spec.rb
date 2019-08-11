describe CampaignHelper do

  let!(:campaign) { create :campaign }

  describe '#campaign_grid_initial_size' do
    it 'returns 12 by default' do
      expect(helper.campaign_grid_initial_size(campaign)).to eq(12)
    end

    it 'returns priority_coupon_ids.count - (count % 4) if count > 12' do
      campaign.priority_coupon_ids = '1,' * 25
      expect(helper.campaign_grid_initial_size(campaign)).to eq(24)
    end
  end

  describe "#campaign_hero_cta" do

    let(:site) { create :site }

    before do
      Site.current = site
      @site = SiteFacade.new(site)
    end

    it "outputs a button with defaults" do
      expect(helper.campaign_hero_cta(campaign)).to include('btn hero__cta')
      expect(helper.campaign_hero_cta(campaign)).to include('#deals')
      expect(helper.campaign_hero_cta(campaign)).to include('Get it!')
    end

    it 'links to header_cta_text if set' do
      campaign.html_document.update(header_cta_text: 'Custom Link')
      expect(helper.campaign_hero_cta(campaign)).to include('Custom Link')
    end

    it 'links to header_cta_anchor_link if set' do
      campaign.html_document.update(header_cta_anchor_link: '#coupons')
      expect(helper.campaign_hero_cta(campaign)).to include('#coupons')
    end

    it 'hides external url if set' do
      campaign.html_document.update(header_cta_anchor_link: 'http://google.de')
      expect(helper.campaign_hero_cta(campaign)).to include("/out/#{ExternalUrl.last.id}")
    end
  end
end
