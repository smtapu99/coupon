describe Shop, type: :model do
  it_behaves_like 'status validator'

  let(:site) { create :site }
  let(:another_site) { create :site }
  let(:fingerprint) { 'c4ebca2aaddb077d80619e8234c471f7' }

  describe 'validates' do
    it 'slug' do
      expect(FactoryGirl.create(:shop, slug: 'ab-a')).to be_valid
      expect{FactoryGirl.create(:shop, slug: 'ab a')}.to raise_error(ActiveRecord::RecordInvalid)
      expect{FactoryGirl.create(:shop, slug: 'óíñ')}.to raise_error(ActiveRecord::RecordInvalid)
      expect{FactoryGirl.create(:shop, slug: 'test&test')}.to raise_error(ActiveRecord::RecordInvalid)
      expect{FactoryGirl.create(:shop, slug: 'electrónica')}.to raise_error(ActiveRecord::RecordInvalid)
      expect{FactoryGirl.create(:shop, slug: 'test?@')}.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '::order_by_set' do
    let!(:shops) { create_list :shop, 2 }
    it 'returns shops ordered by set' do
      expect(Shop.order_by_set(shops.map(&:id)).first).to eq(shops.first)
      expect(Shop.order_by_set(shops.map(&:id).reverse).first).to eq(shops.last)
    end
  end

  describe '::grid_filter' do
    let!(:shop) { create :shop, site: site }
    let!(:another_shop) { create :shop, site: another_site }
    let!(:another_secons_shop) { create :shop, site: another_site }

    it 'returns all shop' do
      expect(Shop.grid_filter({}).count).to eq(3)
    end

    it 'filters by status' do
      shop.update(status: 'blocked')
      expect(Shop.grid_filter(status: ['blocked']).count).to eq(1)
      expect(Shop.grid_filter(status: ['blocked', 'active']).count).to eq(3)
      expect(Shop.grid_filter(status: '').count).to eq(3)
    end

    it 'filters by site_ids' do
      expect(Shop.grid_filter(site_id: site.id).count).to eq(1)
      expect(Shop.grid_filter(site_id: another_site.id).count).to eq(2)
    end

    it 'filters by slug' do
      expect(Shop.grid_filter(slug: shop.slug).count).to eq(1)
      expect(Shop.grid_filter(slug: another_shop.slug).count).to eq(1)
    end

    it 'filters by title' do
      shop.update(title: 'my new title')
      expect(Shop.grid_filter(title: 'my new title').count).to eq(1)
    end

    it 'filters by id' do
      expect(Shop.grid_filter(id: shop.id).count).to eq(1)
    end

    it 'filters by tier_group' do
      Shop.update_all(tier_group: 4)
      shop.update(tier_group: 1)
      expect(Shop.grid_filter(tier_group: 1).count).to eq(1)
    end

    it 'filters by is_hidden' do
      Shop.update_all(is_hidden: false)
      shop.update(is_hidden: 1)
      expect(Shop.grid_filter(is_hidden: 'true').count).to eq(1)
    end

    it 'filters by is_top' do
      Shop.update_all(is_top: false)
      shop.update(is_top: true)
      expect(Shop.grid_filter(is_top: true).count).to eq(1)
    end
  end

  describe '::shops_by_site' do
    before do
      create :shop, site: site
      create_list :shop, 2, site: another_site
    end

    context 'with single site' do
      subject { Shop.shops_by_site([site.id]).count }
      it { is_expected.to eql(1) }
    end

    context 'with multiple sites' do
      subject { Shop.shops_by_site([site.id, another_site.id]).count }
      it { is_expected.to eql(3) }
    end

    context 'with nil' do
      before {
        create :shop, site: site
      }
      subject { Shop.shops_by_site(nil).count }
      it { is_expected.to eql(4) }
    end

    context 'without input' do
      it {
        expect{ Shop.shops_by_site }.to raise_error(ArgumentError)
      }
    end

    context 'with single numeric input' do
      subject { Shop.shops_by_site(site.id).count }
      it { is_expected.to eql(1) }
    end

  end

  describe '.rating' do

    let(:shop) { create :shop, site: site }

    context 'with 1 rating of 5 stars' do
      before {
        shop.add_vote(5, 'test_uid')
      }
      subject { shop.rating }
      it { is_expected.to eql(5.0) }
    end

    context 'with a 5 star rating and a 1 star rating' do
      before {
        shop.add_vote(5, 'test_uid_1')
        shop.add_vote(1, 'test_uid_2')
      }
      subject { shop.rating }
      it { is_expected.to eql(3.0) }
    end

    context 'without any ratings' do
      subject { shop.rating }
      it { is_expected.to eql(0.0) }
    end
  end

  describe '.sitemap_changefreq' do
    let(:shop) { create :shop, site: site }

    it 'returns hourly if tier_group == 1' do
      shop.tier_group = 1
      expect(shop.sitemap_changefreq).to eq('hourly')
    end

    it 'returns daily if tier_group != 1' do
      shop.tier_group = 4
      expect(shop.sitemap_changefreq).to eq('daily')
    end
  end

  describe '.sitemap_priority' do
    let(:shop) { create :shop, site: site }

    it 'returns 0.8 if tier_group = 1' do
      shop.tier_group = 1
      expect(shop.sitemap_priority).to eq('0.8')
    end

    it 'returns 0.6 if tier_group = 2' do
      shop.tier_group = 2
      expect(shop.sitemap_priority).to eq('0.6')
    end

    it 'returns 0.4 if tier_group = 3' do
      shop.tier_group = 3
      expect(shop.sitemap_priority).to eq('0.4')
    end

    it 'returns 0.3 if tier_group > 3' do
      shop.tier_group = 4
      expect(shop.sitemap_priority).to eq('0.3')
    end
  end

  describe '.formatted_rating' do
    let(:shop) { create :shop, site: site }

    before { I18n.locale = 'de-DE' }

    context 'with 1 rating of 5 stars' do
      before {
        shop.add_vote(5, 'test_uid')
      }
      subject { shop.formatted_rating }
      it { is_expected.to eql('5,0') }
    end

    context 'with a 5 star rating and a 1 star rating' do
      before {
        shop.add_vote(5, 'test_uid_1')
        shop.add_vote(1, 'test_uid_2')
      }
      subject { shop.formatted_rating }
      it { is_expected.to eql('3,0') }
    end

    context 'without any ratings' do
      subject { shop.formatted_rating }
      it { is_expected.to eql('0,0') }
    end

    context 'with different locale' do
      before { I18n.locale = 'en-GB' }
      subject { shop.formatted_rating }
      it { is_expected.to eql('0.0') }
    end
  end

  describe '.is_active_and_visible?' do
    let(:shop) { create :shop, site: site }
    let(:hidden_shop) { create :hidden_shop, site: site }

    context 'with active and visible shop' do
      it { expect(shop.is_active_and_visible?).to eq(true) }
    end

    context 'with active and hidden shop' do
      it { expect(hidden_shop.is_active_and_visible?).to eq(false) }
    end
  end

  describe '.logo_url' do
    let(:shop) { create :shop, site: site }

    it 'returns default if logo is null' do
      shop.logo = nil
      expect(shop.logo_url).to eq('/assets/shop_logo_default.png')
    end
  end

  describe '.has_valid_payment_methods?' do
    let(:shop) { create :shop, site: site }
    let(:shop_with_wrong_data) { create :shop, :with_wrong_payment_methods, site: site }

    context 'with wrong payment methods' do
      it { expect(shop_with_wrong_data.has_valid_payment_methods?).to eq(false) }
    end

    context 'with valid payment methods' do
      it { expect(shop.has_valid_payment_methods?).to eq(true) }
    end
  end

  describe '.has_valid_delivery_methods?' do
    let(:shop) { create :shop, site: site }
    let(:shop_with_wrong_data) { create :shop, :with_wrong_delivery_methods, site: site }

    context 'with wrong delivery methods' do
      it { expect(shop_with_wrong_data.has_valid_delivery_methods?).to eq(false) }
    end

    context 'with valid delivery methods' do
      it { expect(shop.has_valid_delivery_methods?).to eq(true) }
    end
  end

  describe '.indexed' do
    context 'without matching records' do
      before { create :shop, :with_html_document_noindex }
      subject { Shop.indexed }
      it { is_expected.to be_empty }
    end

    context 'with matching records' do
      before { create :shop, :with_html_document_index }
      subject { Shop.indexed }
      it { is_expected.not_to be_empty }
    end

    context 'with html_document.meta_robots nil' do
      before { create :shop, :with_html_document_robots_nil }
      subject { Shop.indexed }
      it { is_expected.not_to be_empty }
    end
  end
end
