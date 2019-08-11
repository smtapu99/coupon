describe VueData::AffiliateNetwork do

  context '::render_json' do
    let!(:affiliate_networks) { create_list :affiliate_network, 2 }

    context 'succeeds' do
      it 'returns affiliate networks' do
        expect(JSON.parse(VueData::AffiliateNetwork.render_json(nil))['count']).to eq(affiliate_networks.count)
      end

    end

    context 'response' do
      subject { JSON.parse(VueData::AffiliateNetwork.render_json(nil))['records'].first.keys }
      it { is_expected.to match_array(%w(id status name slug)) }
    end
  end
end
