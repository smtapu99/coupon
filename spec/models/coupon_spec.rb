describe Coupon, :type => :model do
  it_behaves_like 'status validator'

  let(:site) { create :site }
  let(:shop) { create :shop, site_id: site.id }
  let(:another_site) { create :site }
  let(:another_shop) { create :shop, site: another_site }

  describe '::order_by_set' do
    let!(:coupons) { create_list :coupon, 2 }
    it 'returns coupons ordered by set' do
      expect(Coupon.order_by_set(coupons.map(&:id)).first).to eq(coupons.first)
      expect(Coupon.order_by_set(coupons.map(&:id).reverse).first).to eq(coupons.last)
    end
  end

  describe '::status_active' do
    let!(:active) { create :coupon, status: 'active' }
    let!(:blocked) { create :coupon, status: 'blocked' }
    it 'returns active coupons' do
      expect(Coupon.status_active).to eq([active])
    end
  end

  describe '::active' do
    let!(:unexpired) { create :coupon }
    let!(:expired) { create :coupon, end_date: 1.minute.ago }

    it 'returns active unexpired coupons' do
      expect(Coupon.active).to eq([unexpired])
      unexpired.update(status: 'blocked')
      expect(Coupon.active).to eq([])
    end
  end

  describe '::unexpired' do
    let!(:unexpired) { create :coupon, status: 'blocked' }
    let!(:expired) { create :coupon, end_date: 1.minute.ago }

    it 'returns unexpired coupons even if blocked' do
      expect(Coupon.unexpired).to eq([unexpired])
      unexpired.update(end_date: Time.zone.now - 1.day)
      expect(Coupon.unexpired).to eq([])
    end
  end

  describe '::order_by_campaign_priority' do
    let!(:coupons) { create_list :coupon, 2, priority_score: 1 }

    it 'with set returns coupons ordered by set' do
      expect(Coupon.order_by_campaign_priority(coupons.map(&:id)).first).to eq(coupons.first)
      expect(Coupon.order_by_campaign_priority(coupons.map(&:id).reverse).first).to eq(coupons.last)
    end

    it 'without set returns coupons ordered by priority_score' do
      expect(Coupon.order_by_campaign_priority.first).to eq(coupons.first)
      coupons.last.update(priority_score: 2)
      expect(Coupon.order_by_campaign_priority.first).to eq(coupons.last)
    end
  end

  describe '::visible' do
    let!(:coupons) { create_list :coupon, 2 }
    before { coupons.first.update(is_hidden: true) }

    it 'without allowed_ids' do
      expect(Coupon.visible).to include(coupons.last)
    end

    it 'with allowed_ids' do
      expect(Coupon.visible(coupons.first.id)).to include(coupons.first, coupons.last)
    end
  end

  describe '::coupons_by_site' do
    before {
      create_list :coupon, 2, site: site, shop: shop
      create_list :coupon, 3, site: another_site, shop: another_shop
    }

    context 'with single site' do
      subject { Coupon.coupons_by_site([site.id]).count }
      it { is_expected.to eql(2) }
    end

    context 'with multiple sites' do
      subject { Coupon.coupons_by_site([site.id, another_site.id]).count }
      it { is_expected.to eql(5) }
    end

    context 'with nil' do
      before {
        create :coupon, site: site, shop: shop
      }
      subject { Coupon.coupons_by_site(nil).count }
      it { is_expected.to eql(6) }
    end

    context 'without input' do
      it {
        expect{ Coupon.coupons_by_site }.to raise_error(ArgumentError)
      }
    end

    context 'with single numeric input' do
      subject { Coupon.coupons_by_site(site.id).count }
      it { is_expected.to eql(2) }
    end

  end

  describe '::calculate_priorities' do

    let(:coupon) { create :coupon, site: site, shop: shop }
    let(:inactive_coupon) { create :coupon, site: site, shop: shop, status: 'blocked' }

    def calculate_priority_score coupon, shop
      date_diff = (Date.today - (coupon.start_date.present? ? coupon.start_date.to_date : coupon.created_at.to_date)).to_i
      ((coupon.clicks > 0 ? coupon.clicks : 1) / (date_diff > 0 ? date_diff : 1) * (shop.clickout_value == 0 ? 0.00001 : shop.clickout_value) * (Shop::PRIORITY_COUNT / shop.tier_group)).to_f
    end

    before do
      coupon.start_date = Time.zone.now - 1.day
      shop.clickout_value = 5
      coupon.clicks = 1000
      shop.tier_group = 1
      coupon.save
      shop.save
    end

    it 'calculates the correct priority' do
      Coupon::calculate_priorities(site)

      expect(coupon.reload.priority_score).to eq (calculate_priority_score coupon, shop)
      expect(coupon.reload.priority_score).to_not eq (0.0)
    end


    it 'calculates the correct priority if shop.clickout_value is 0' do
      shop.update_attribute(:clickout_value, 0)

      Coupon::calculate_priorities(site)

      expect(coupon.reload.priority_score).to eq (calculate_priority_score coupon, shop)
      expect(coupon.reload.priority_score).to_not eq (0.0)
    end

    it 'calculates the correct priority if coupon.clicks is 0' do
      coupon.update_attribute(:clicks, 0)

      Coupon::calculate_priorities(site)

      expect(coupon.reload.priority_score).to eq (calculate_priority_score coupon, shop)
      expect(coupon.reload.priority_score).to_not eq (0.0)
    end

    it 'limits score to 99999 if score is higher then 99999' do
      coupon.update_attribute(:clicks, 10000)

      Coupon::calculate_priorities(site)

      expect(coupon.reload.priority_score).to eq (99999.to_f)
    end

    it 'doesnt fail if coupon.start_date is today' do
      coupon.update_attribute(:start_date, Time.zone.now)

      Coupon::calculate_priorities(site)

      expect(coupon.reload.priority_score).to eq (calculate_priority_score coupon, shop)
      expect(coupon.reload.priority_score).to_not eq (0.0)
    end

    it 'only updates active coupons' do
      inactive_coupon.save

      Coupon::calculate_priorities(site)

      expect(inactive_coupon.reload.priority_score).to eq (0.0)
    end

  end

  describe '::grid_filter' do
    before do
      create_list :coupon, 2, site: site, shop: shop
      create_list :coupon, 3, site: another_site, shop: another_shop
    end

    it 'returns all coupons' do
      expect(Coupon.grid_filter({})).to match_array(Coupon.all)
    end

    it 'returns only non-exired coupons by default' do
      Coupon.where(shop_id: shop).update_all(end_date: Time.zone.now - 1.year)
      Coupon.where(shop_id: another_shop).update_all(end_date: Time.zone.now + 1.year)
      expect(Coupon.grid_filter({}).count).to eq(3)
    end

    it 'returns also exired coupons if true' do
      Coupon.where(shop_id: shop).update_all(end_date: Time.zone.now - 1.year)
      Coupon.where(shop_id: another_shop).update_all(end_date: Time.zone.now + 1.year)
      expect(Coupon.grid_filter({'expired' => 'true'}).count).to eq(2)
    end

    it 'filters by status' do
      Coupon.where(shop_id: shop).update(status: 'blocked')
      expect(Coupon.grid_filter(status: ['blocked']).count).to eq(2)
      expect(Coupon.grid_filter(status: ['blocked', 'active']).count).to eq(5)
      expect(Coupon.grid_filter(status: '').count).to eq(5)
    end

    it 'filters by site_ids' do
      expect(Coupon.grid_filter(site_id: site.id).count).to eq(2)
      expect(Coupon.grid_filter(site_id: another_site.id).count).to eq(3)
    end

    it 'filters by shop_slugs' do
      expect(Coupon.grid_filter(shop_slug: shop.slug).count).to eq(2)
      expect(Coupon.grid_filter(shop_slug: another_shop.slug).count).to eq(3)
    end

    it 'filters by end_date' do
      Coupon.where(shop_id: shop).first.update(end_date: '2017-12-30 00:00:00'.to_time)
      Coupon.where(shop_id: shop).last.update(end_date: '2017-12-31 23:59:59'.to_time)
      expect(Coupon.grid_filter(site_id: site.id, expired: 'all', end_date_from: '2017-12-30', end_date_to: '2017-12-31').count).to eq(2)
      expect(Coupon.grid_filter(site_id: site.id, expired: 'all', end_date_from: '2017-12-31').count).to eq(1)
      expect(Coupon.grid_filter(site_id: site.id, expired: 'all', end_date_to: '2017-12-30').count).to eq(1)
    end

    it 'filters by start_date' do
      Coupon.where(shop_id: shop).first.update(start_date: '2017-12-30 00:00:00'.to_time)
      Coupon.where(shop_id: shop).last.update(start_date: '2017-12-31 23:59:59'.to_time)
      expect(Coupon.grid_filter(site_id: site.id, expired: 'all', start_date_from: '2017-12-30', start_date_to: '2017-12-31').count).to eq(2)
      expect(Coupon.grid_filter(site_id: site.id, expired: 'all', start_date_from: '2017-12-31').count).to eq(1)
      expect(Coupon.grid_filter(site_id: site.id, expired: 'all', start_date_to: '2017-12-30').count).to eq(1)
    end

    it 'filters by created_at' do
      Coupon.where(shop_id: shop).first.update(created_at: '2017-12-30 00:00:00'.to_time)
      Coupon.where(shop_id: shop).last.update(created_at: '2017-12-31 23:59:59'.to_time)
      expect(Coupon.grid_filter(site_id: site.id, expired: 'all', created_at_from: '2017-12-30', created_at_to: '2017-12-31').count).to eq(2)
      expect(Coupon.grid_filter(site_id: site.id, expired: 'all', created_at_from: '2017-12-31').count).to eq(1)
      expect(Coupon.grid_filter(site_id: site.id, expired: 'all', created_at_to: '2017-12-30').count).to eq(1)
    end
  end

  describe '::export' do
    let(:category) { create :category, site: site }
    let(:another_category) { create :category, site: another_site }

    let(:start_date) {{
      'start_date_from(1i)' => '2017',
      'start_date_from(2i)' => '1',
      'start_date_from(3i)' => '1',
      'start_date_from(4i)' => '00',
      'start_date_from(5i)' => '00',
      'start_date_to(1i)' => '2017',
      'start_date_to(2i)' => '12',
      'start_date_to(3i)' => '31',
      'start_date_to(4i)' => '23',
      'start_date_to(5i)' => '59'
    }}

    let(:end_date) {{
      'end_date_from(1i)' => '2017',
      'end_date_from(2i)' => '1',
      'end_date_from(3i)' => '1',
      'end_date_from(4i)' => '00',
      'end_date_from(5i)' => '00',
      'end_date_to(1i)' => '2017',
      'end_date_to(2i)' => '12',
      'end_date_to(3i)' => '31',
      'end_date_to(4i)' => '23',
      'end_date_to(5i)' => '59'
    }}

    let(:created_at) {{
      'created_at_from(1i)' => '2017',
      'created_at_from(2i)' => '1',
      'created_at_from(3i)' => '1',
      'created_at_from(4i)' => '00',
      'created_at_from(5i)' => '00',
      'created_at_to(1i)' => '2017',
      'created_at_to(2i)' => '12',
      'created_at_to(3i)' => '31',
      'created_at_to(4i)' => '23',
      'created_at_to(5i)' => '59'
    }}

    before do
      create_list :coupon, 2, site: site, shop: shop
      create_list :coupon, 3, site: another_site, shop: another_shop
    end

    it 'returns all coupons' do
      expect(Coupon.export({})).to match_array(Coupon.all)
    end

    it 'returns only non-exired coupons by default' do
      Coupon.where(shop_id: shop).update_all(end_date: Time.zone.now - 1.year)
      Coupon.where(shop_id: another_shop).update_all(end_date: Time.zone.now + 1.year)
      expect(Coupon.export({}).count).to eq(3)
    end

    it 'returns also exired coupons if requested' do
      Coupon.where(shop_id: shop).update_all(end_date: Time.zone.now - 1.year)
      Coupon.where(shop_id: another_shop).update_all(end_date: Time.zone.now + 1.year)
      expect(Coupon.export({'include_expired' => 1}).count).to eq(5)
    end

    it 'filters by status' do
      Coupon.where(shop_id: shop).update(status: 'blocked')
      expect(Coupon.export({status: ['blocked']}).count).to eq(2)
      expect(Coupon.export({status: ['blocked', 'active']}).count).to eq(5)
    end

    it 'filters by shop.tier_group' do
      shop.update(tier_group: 1)
      another_shop.update(tier_group: 2)
      expect(Coupon.export({shop_tier_group: [1]}).count).to eq(2)
      expect(Coupon.export({shop_tier_group: [1,2]}).count).to eq(5)
    end

    it 'filters by coupon_type' do
      Coupon.where(shop_id: shop).update(coupon_type: 'coupon', code: 'abc')
      Coupon.where(shop_id: another_shop).update(coupon_type: 'offer')
      expect(Coupon.export({coupon_type: ['coupon']}).count).to eq(2)
      expect(Coupon.export({coupon_type: ['coupon', 'offer']}).count).to eq(5)
    end

    it 'filters by site_ids' do
      expect(Coupon.export(site_ids: [site.id]).count).to eq(2)
      expect(Coupon.export(site_ids: [another_site.id]).count).to eq(3)
    end

    it 'filters by shop_slugs' do
      expect(Coupon.export(shop_slugs: "#{shop.slug}, #{another_shop.slug}").count).to eq(5)
      expect(Coupon.export(shop_slugs: "#{another_shop.slug}").count).to eq(3)
    end

    it 'filters by affilate_network_ids' do
      Coupon.where(shop_id: another_shop).update(affiliate_network_id: 100)
      expect(Coupon.export(affiliate_network_id: [100]).count).to eq(3)
    end

    it 'filters by category_ids' do
      Coupon.where(shop_id: shop).update(category_ids: [category.id])
      Coupon.where(shop_id: another_shop).update(category_ids: [another_category.id])
      expect(Coupon.export(category_ids: [category.id, another_category.id]).count).to eq(5)
      expect(Coupon.export(category_ids: [category.id]).count).to eq(2)
    end

    it 'filters by end_date' do
      Coupon.where(shop_id: shop).update(end_date: '2017-12-31 23:59:59')
      expect(Coupon.export(end_date).count).to eq(2)

      Coupon.where(shop_id: shop).update(end_date: '2016-12-31 23:59:59')
      expect(Coupon.export(end_date).count).to eq(0)
    end

    it 'filters by start_date' do
      Coupon.where(shop_id: shop).update(start_date: '2017-01-01 00:00:00')
      expect(Coupon.export(start_date).count).to eq(2)

      Coupon.where(shop_id: shop).update(start_date: '2018-01-01 00:00:00')
      expect(Coupon.export(start_date).count).to eq(0)
    end

    it 'filters by created_at' do
      Coupon.where(shop_id: shop).update(created_at: '2017-01-01 00:00:00')
      expect(Coupon.export(created_at).count).to eq(2)

      Coupon.where(shop_id: shop).update(created_at: '2018-01-01 00:00:00')
      expect(Coupon.export(created_at).count).to eq(0)
    end
  end

  describe '.has_default_behaviour?' do
    context 'when shop.is_default_clickout = false and coupon is offer' do
      before { shop.update(is_default_clickout: false) }
      subject { build(:coupon, shop: shop, coupon_type: 'offer').has_default_behaviour? }
      it { is_expected.to eq(false) }
    end
    context 'when shop.is_default_clickout = false but coupon has code' do
      before { shop.update(is_default_clickout: false) }
      subject { build(:coupon, shop: shop, code: '123', coupon_type: 'coupon').has_default_behaviour? }
      it { is_expected.to eq(true) }
    end
  end

  describe '.has_savings?' do
    let(:savings_coupon) { create :coupon, site: site, shop: shop, savings: 10 }
    let(:rounded_zero_savings_coupon) { create :coupon, site: site, shop: shop, savings: 0.4892323 }
    let(:rounded_one_savings_coupon) { create :coupon, site: site, shop: shop, savings: 0.504383293 }
    let(:no_savings_coupon) { create :coupon, site: site, shop: shop }

    context 'with savings of 10' do
      subject { savings_coupon.has_savings? }
      it { is_expected.to be_truthy }
    end

    context 'with savings rounded to 0' do
      subject { rounded_zero_savings_coupon.has_savings? }
      it { is_expected.to be_falsey }
    end

    context 'with savings rounded to 1' do
      subject { rounded_one_savings_coupon.has_savings? }
      it { is_expected.to be_truthy }
    end

    context 'without savings' do
      subject { no_savings_coupon.has_savings? }
      it { is_expected.to be_falsey }
    end
  end

  describe '.savings_in_symbol' do
    let!(:coupon) { create :coupon, site: site }

    before do
      site.country.update(locale: 'pt-BR')
      Site.current = site
      I18n.global_scope = :frontend
      I18n.locale = 'pt-BR'
    end

    it 'returns coupons.currency if set' do
      coupon.update(currency: 'руб.')
      expect(coupon.savings_in_symbol).to eq('руб.')
    end

    it 'returns I18n.t :SAVINGS_IN_CURRENCY if set' do
      create :translation, locale: 'pt-BR', key: 'SAVINGS_IN_CURRENCY', value: '€'
      expect(coupon.savings_in_symbol).to eq('€')
    end

    it 'returns Site.site_currency' do
      site.country.update(locale: 'pt-BR')
      expect(coupon.savings_in_symbol).to eq('R$')
    end
  end

  context '.invalid_urls_filter' do
    let!(:affiliate_network) { create :affiliate_network, validation_regex: '^http://awin\.com$' }
    context 'when url matches' do
      let!(:coupon) { create :coupon, site: site, url: 'http://awin.com', affiliate_network: affiliate_network }
      subject { Coupon.invalid_urls_filter({}) }
      it { is_expected.to eq([]) }
    end

    context 'when url doesnt match' do
      let!(:coupon) { create :coupon, site: site, url: 'http://zanox.com', affiliate_network: affiliate_network }
      subject { Coupon.invalid_urls_filter({}) }
      context 'and coupon is active' do
        it { is_expected.to eq([coupon]) }
      end
      context 'and coupon is expired' do
        before { coupon.update(end_date: Time.zone.now - 1.day) }
        it { is_expected.to eq([]) }
      end
      context 'and coupon isnt active' do
        before { coupon.update(status: 'blocked') }
        it { is_expected.to eq([]) }
      end
      context 'and shop is inactive' do
        before { coupon.shop.update(status: 'blocked') }
        it { is_expected.to eq([]) }
      end
    end
  end

  describe '.savings_in_string' do
    before do
      I18n.locale = 'en-US'
      Site.current = site
    end

    context 'with percentage' do
      let!(:coupon) { create :coupon, savings: 10, savings_in: :percent, currency: nil }

      it 'returns the boldified savings string' do
        expect(coupon.savings_in_string).to eq('<b>10</b>%')
      end

      it 'returns the non boldified savings string' do
        expect(coupon.savings_in_string(false)).to eq('10%')
      end
    end

    context 'with default currency' do
      let!(:coupon) { create :coupon, savings: 10, savings_in: :currency, currency: nil }

      it 'returns the boldified savings string' do
        expect(coupon.savings_in_string).to eq('<b>10</b>$')
      end

      it 'returns the non boldified savings string' do
        expect(coupon.savings_in_string(false)).to eq('10$')
      end
    end

    context 'with publisher_site.currency_symbol_position == left' do
      let!(:coupon) { create :coupon, savings: 10, savings_in: :currency, currency: nil }
      let!(:setting) { create :setting, publisher_site: { currency_symbol_position: 'left' }, site: site }

      it 'returns percentage on right' do
        coupon.update(savings_in: 'percent')
        expect(coupon.savings_in_string).to eq('<b>10</b>%')
      end

      it 'returns the boldified savings string' do
        expect(coupon.savings_in_string).to eq('$<b>10</b>')
      end

      it 'returns the non boldified savings string' do
        expect(coupon.savings_in_string(false)).to eq('$10')
      end
    end

    context 'with dedicated currency' do
      let!(:coupon) { create :coupon, savings: 10, savings_in: :currency, currency: '€' }

      it 'returns the boldified savings string' do
        expect(coupon.savings_in_string).to eq('<b>10</b>€')
      end

      it 'returns the non boldified savings string' do
        expect(coupon.savings_in_string(false)).to eq('10€')
      end
    end
  end

  describe '.uniq_coupon_code' do
    let!(:coupon) { create :coupon, use_uniq_codes: true, site: site, code: 'my code', coupon_type: 'coupon' }
    let!(:codes) { create_list :coupon_code, 5, coupon_id: coupon.id, site: site }
    let!(:tracking_user) { create :tracking_user }

    before do
      Site.current = site
    end

    it 'returns coupons.code unless tracking_user present?' do
      expect(coupon.uniq_coupon_code(nil)).to eq('my code')
    end

    it 'returns coupons.code if use_uniq_codes == false' do
      coupon.use_uniq_codes = false
      expect(coupon.uniq_coupon_code(tracking_user)).to eq('my code')
    end

    it 'returns the next unused code and marks the code as used' do
      expect(coupon.uniq_coupon_code(tracking_user)).to eq(codes.first.code)
      expect(coupon.uniq_coupon_code(tracking_user)).to eq(codes.first.code)
      expect(codes.first.reload.used_at).to_not eq(nil)
      expect(codes.first.reload.tracking_user_id).to eq(tracking_user.id)
    end
  end

  describe '.prioritize_exclusive_coupons' do

    context 'if new_record?' do
      let(:coupon) { build :coupon, shop_list_priority: 5 }
      it 'does nothing unless is_exclusive' do
        coupon.save
        expect(coupon.reload.shop_list_priority).to eq(5)
      end

      it 'sets the shop_list_priority to 1 if is_exclusive and prio is 5' do
        coupon.is_exclusive = true
        coupon.save
        expect(coupon.shop_list_priority).to eq(1)
      end

      it 'sets the shop_list_priority to 1 if is_editors_pick and prio is 5' do
        coupon.is_editors_pick = true
        coupon.save
        expect(coupon.shop_list_priority).to eq(1)
      end

      it 'does nothing if exclusive but with prio other then 5' do
        coupon.is_exclusive = true
        coupon.shop_list_priority = 3
        coupon.save
        expect(coupon.reload.shop_list_priority).to eq(3)
      end

      it 'does nothing if is_editors_pick but with prio other then 5' do
        coupon.is_editors_pick = true
        coupon.shop_list_priority = 3
        coupon.save
        expect(coupon.reload.shop_list_priority).to eq(3)
      end
    end

    context 'if updated' do
      let!(:coupon) { create :coupon, shop_list_priority: 5 }
      it 'does nothing unless is_exclusive' do
        coupon.save
        expect(coupon.reload.shop_list_priority).to eq(5)
      end

      it 'sets the shop_list_priority to 1 if is_exclusive and prio is 5' do
        coupon.is_exclusive = true
        coupon.save
        expect(coupon.shop_list_priority).to eq(1)
      end

      it 'sets the shop_list_priority to 1 if is_editors_pick? and prio is 5' do
        coupon.is_editors_pick = true
        coupon.save
        expect(coupon.shop_list_priority).to eq(1)
      end

      it 'does nothing if exclusive but with prio other then 5' do
        coupon.is_exclusive = true
        coupon.shop_list_priority = 3
        coupon.save
        expect(coupon.shop_list_priority).to eq(3)
      end

      it 'does nothing if is_editors_pick but with prio other then 5' do
        coupon.is_editors_pick = true
        coupon.shop_list_priority = 3
        coupon.save
        expect(coupon.shop_list_priority).to eq(3)
      end
    end
  end

  context '.joined_category_slugs' do
    let(:coupon) { create :coupon, categories: create_list(:category, 2, site: site), site: site  }
    subject { coupon.joined_category_slugs }
    it { is_expected.to eq Category.pluck(:slug).join(',') }
  end

  context '.joined_campaign_slugs' do
    let(:coupon) { create :coupon, campaigns: create_list(:campaign, 2, site: site), site: site  }
    subject { coupon.joined_campaign_slugs }
    it { is_expected.to eq Campaign.pluck(:slug).join(',') }
  end

  context '.has_expired' do
    context 'when expired' do
      subject { build(:coupon, end_date: Time.zone.now - 1.minute).has_expired? }
      it { is_expected.to eq(true) }
    end

    context 'when not expired' do
      subject { build(:coupon, end_date: Time.zone.now + 1.minute).has_expired? }
      it { is_expected.to eq(false) }
    end
  end

  context '.is_coupon?' do
    subject { build(:coupon, code: '123', coupon_type: 'coupon').is_coupon? }
    it { is_expected.to eq(true) }
  end

  context '.is_new?' do
    context 'when start_date nil uses created_at' do
      subject { build(:coupon, start_date: nil, created_at: 1.minute.ago).is_new? }
      it { is_expected.to eq(true) }
    end

    context 'when start_date < 3.days.ago' do
      subject { build(:coupon, start_date: 1.days.ago).is_new? }
      it { is_expected.to eq(true) }
    end

    context 'when start_date > 3.days.ago' do
      subject { build(:coupon, start_date: 4.days.ago).is_new? }
      it { is_expected.to eq(false) }
    end
  end

  context '.is_offer?' do
    subject { build(:coupon, coupon_type: 'offer').is_offer? }
    it { is_expected.to eq(true) }
  end

  context '.is_percentage?' do
    subject { build(:coupon, savings_in: 'percent').is_percentage? }
    it { is_expected.to eq(true) }
  end

  context '.is_currency?' do
    subject { build(:coupon, savings_in: 'currency').is_currency? }
    it { is_expected.to eq(true) }
  end
end
