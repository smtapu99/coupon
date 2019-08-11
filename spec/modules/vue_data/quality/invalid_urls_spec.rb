describe VueData::Quality::ActiveCoupons do
  let(:site) { create :site }

  context '::render_json' do
    let!(:affiliate_network) { create :affiliate_network, validation_regex: '^https://an.com$'}
    let!(:coupon) { create :coupon, site: site, affiliate_network: affiliate_network, url: 'https://an.com' }
    let!(:wrong_coupons) { create_list :coupon, 2, site: site, affiliate_network: affiliate_network }

    context 'succeeds' do
      it 'with single site' do
        expect(JSON.parse(VueData::Quality::InvalidUrls.render_json(site.id))['count']).to eq(wrong_coupons.count)
      end

      it 'without sites' do
        expect(JSON.parse(VueData::Quality::InvalidUrls.render_json(nil))['count']).to eq(wrong_coupons.count)
      end
    end

    context 'returns' do
      subject { JSON.parse(VueData::Quality::InvalidUrls.render_json(site.id))['records'].first.keys }

      it { is_expected.to match_array(%w(id edit_path shop_slug affiliate_network_slug url)) }
    end
  end
end
