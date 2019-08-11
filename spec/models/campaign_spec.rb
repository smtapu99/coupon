describe Campaign do
  it_behaves_like 'status validator'

  it "has a valid factory" do
    expect(build(:campaign)).to be_valid
  end
  it "validates status" do
    expect(build(:campaign, status: 'wrong')).to_not be_valid
  end

  it "is invalid without a site_id" do
    expect(build(:campaign, site_id: nil)).not_to be_valid
  end

  it "is invalid without a name" do
    expect(build(:campaign, name: nil)).not_to be_valid
  end

  it "returns site_id" do
    campaign = build(:campaign)
    expect(campaign.site_id).not_to eq nil
  end

  it "is invalid with SEM template and shop_id" do
    expect(build(:campaign, template: :sem, shop_id: 1)).to_not be_valid
  end

  it "is invalid with SEM template and parent_id" do
    expect(build(:campaign, template: :sem, parent_id: 1)).to_not be_valid
  end

  it "is invalid with is_root_campaign = true and shop_id" do
    expect(build(:campaign, is_root_campaign: true, shop_id: 1)).to_not be_valid
  end

  it 'is invalid with more then 48 priority_coupon_ids' do
    ids = ''
    (1..49).each { |i| ids += "#{i}," }
    expect(ids.split(',').length).to eq(49)
    expect(build(:campaign, priority_coupon_ids: ids)).to_not be_valid
  end

  describe '::without_sem' do
    subject { Campaign.without_sem }
    let!(:campaign) { create :campaign, template: 'SEM' }

    context 'when campaign is SEM' do
      it { is_expected.to eq [] }
    end

    context 'when campaign is NOT SEM' do
      before { campaign.update(template: 'default') }
      it { is_expected.to eq [campaign] }
    end
  end

  describe '::campaigns_for_sitemap' do
    subject { Campaign.campaigns_for_sitemap }

    context 'when campaign is active, not SEM and indexed' do
      let!(:campaign) { create :campaign }
      it { is_expected.to eq [campaign] }
    end

    context 'when campaign is SEM?' do
      let!(:campaign) { create :campaign, template: 'SEM' }
      it { is_expected.to eq [] }
    end

    context 'when campaign is noindex' do
      let!(:campaign) { create :campaign, :with_html_document_noindex }
      it { is_expected.to eq [] }
    end

    context 'when campaign is index' do
      let!(:campaign) { create :campaign, :with_html_document_index }
      it { is_expected.to eq [campaign] }
    end

    context 'when campaign is gone' do
      let!(:campaign) { create :campaign, :with_html_document_index }
      it { is_expected.to eq [campaign] }
    end

    context 'when campaign is active' do
      let!(:campaign) { create :campaign, status: :active }
      it { is_expected.to eq [campaign] }
    end

    context 'when campaign is inactive' do
      let!(:campaign) { create :campaign, status: :blocked }
      it { is_expected.to eq [] }
    end

    context 'when campaign is gone' do
      let!(:campaign) { create :campaign, status: :gone }
      it { is_expected.to eq [] }
    end
  end

  describe '::order_by_set' do
    let!(:campaigns) { create_list :campaign, 5 }
    it 'returns campaigns ordered by set' do
      expect(Campaign.order_by_set(campaigns.map(&:id)).first).to eq(campaigns.first)
      expect(Campaign.order_by_set(campaigns.map(&:id).reverse).first).to eq(campaigns.last)
    end
  end

  describe '::indexed' do
    context 'without matching records' do
      let!(:campaign) { create :campaign, :with_html_document_noindex }
      subject { Campaign.indexed }
      it { is_expected.to be_empty }
    end

    context 'with matching records' do
      before {
        create :campaign, :with_html_document_index
      }
      subject { Campaign.indexed }
      it { is_expected.not_to be_empty }
    end
  end

  describe '.priority_coupon_ids_array' do
    let(:campaign) { create :campaign, priority_coupon_ids: '1, 2' }
    it 'returns an array of priority_coupon_ids' do
      expect(campaign.priority_coupon_ids_array).to eq([1, 2])
    end
  end

  describe '.has_inactive_parent?' do
    subject { campaign.has_inactive_parent? }

    context 'when shop' do
      let!(:shop) { create :shop }
      let!(:campaign) { create :campaign, shop: shop }

      context 'is nil' do
        before { campaign.update(shop: nil) }
        it { is_expected.to eq(false) }
      end
      context 'is active' do
        it { is_expected.to eq(false) }
      end
      context 'is != active' do
        before { shop.update(status: 'inactive') }
        it { is_expected.to eq(true) }
      end
    end

    context 'when parent' do
      let!(:parent) { create :campaign }
      let!(:campaign) { create :campaign, parent: parent }

      context 'is nil' do
        before { campaign.update(parent: nil) }
        it { is_expected.to eq(false) }
      end
      context 'is active' do
        it { is_expected.to eq(false) }
      end
      context 'is != active' do
        before { parent.update(status: 'inactive') }
        it { is_expected.to eq(true) }
      end
    end
  end

  describe '.id_and_name'

  describe '.parent_or_shop_present?' do
    subject { campaign.parent_or_shop_present? }

    context 'when shop' do
      let!(:shop) { create :shop }
      let!(:campaign) { create :campaign, shop: shop }

      context 'is nil' do
        before { campaign.update(shop: nil) }
        it { is_expected.to eq(false) }
      end
      context 'is present' do
        it { is_expected.to eq(true) }
      end
    end

    context 'when parent' do
      let!(:parent) { create :campaign }
      let!(:campaign) { create :campaign, parent: parent }

      context 'is nil' do
        before { campaign.update(parent: nil) }
        it { is_expected.to eq(false) }
      end
      context 'is present' do
        it { is_expected.to eq(true) }
      end
    end
  end

  describe '.sitemap_priority' do
    let!(:site) { create :site }
    let!(:campaign) { create :campaign, site: site }
    let!(:setting) { create :setting, menu: { main_campaign_ids: [campaign.id] }, site: site }

    before { Site.current = site }

    it 'returns 0.6 if campaign in setting menu.main_campaign_ids' do
      expect(campaign.sitemap_priority).to eq('0.6')
    end

    it 'returns 0.3 if not' do
      setting.update(menu: { main_campaign_ids: [] })
      expect(campaign.sitemap_priority).to eq('0.3')
    end
  end
end
