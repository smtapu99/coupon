describe VueData::Coupon do
  let(:site) { create :site }
  let(:another_site) { create :site }

  context '::render_json' do
    let(:shop) { create :shop, site_id: site.id }
    let(:another_shop) { create :shop, site: another_site }

    let!(:coupons) { create_list :coupon, 2, site: site, shop: shop }
    let!(:other_coupons) { create_list :coupon, 3, site: another_site, shop: another_shop }

    context 'succeeds' do
      it 'with single site' do
        expect(JSON.parse(VueData::Coupon.render_json(site.id))['count']).to eq(coupons.count)
      end

      it 'with multiple sites' do
        expect(JSON.parse(VueData::Coupon.render_json([site.id, another_site.id]))['count']).to eq(Coupon.count)
      end

      it 'with order by affiliate_network_slug' do
        expect(JSON.parse(VueData::Coupon.render_json(site.id, order: 'affiliate_network_slug', direction: 'asc'))['count']).to eq(coupons.count)
      end

      it 'with order by shop_slug' do
        expect(JSON.parse(VueData::Coupon.render_json(site.id, order: 'shop_slug', direction: 'asc'))['count']).to eq(coupons.count)
      end
    end

    context 'returns' do
      subject { JSON.parse(VueData::Coupon.render_json(site.id))['records'].first.keys }

      it { is_expected.to match_array(%w(id status affiliate_network_slug shop_slug code is_top is_exclusive is_free start_date end_date created_at priority_score expired title)) }
    end
  end
end
