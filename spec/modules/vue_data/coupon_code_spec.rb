describe VueData::CouponCode do
  let(:site) { create :site }
  let(:other_site) { create :site }
  let(:other_shop) { create :shop, site: other_site }
  let(:other_coupon) { create :coupon, shop: other_shop, site: other_site }

  context '::render_json' do
    let!(:coupon_codes) { create_list :coupon_code, 2, :with_coupon, site: site}
    let!(:other_coupon_code) { create :coupon_code, coupon: other_coupon, site: other_site}

    context 'succeeds' do

      it 'with single site' do
        expect(JSON.parse(VueData::CouponCode.render_json(site.id))['count']).to eq(coupon_codes.count)
      end

      it 'with multiple sites' do
        expect(JSON.parse(VueData::CouponCode.render_json([site.id, other_site.id]))['count']).to eq(CouponCode.count)
      end

    end

    context 'returns' do
      subject { JSON.parse(VueData::CouponCode.render_json(site.id))['records'].first.keys }

      it { is_expected.to match_array(%w(id coupon_id code tracking_user_id is_imported end_date used_at created_at updated_at)) }
    end
  end
end
