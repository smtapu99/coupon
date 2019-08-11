describe VueData::Global::ShopMapping do

  context '::render_json' do
    let!(:country) { create :country }
    let!(:globals) { create_list :global, 2 }
    let!(:site) { create :site }
    let!(:shops) { create_list :shop, 2, global_id: globals.first.id, site_id: site.id }

    context 'succeeds' do
      it 'returns uniq globals' do
        expect(JSON.parse(VueData::Global::ShopMapping.render_json(nil, country_id: country.id))['count']).to eq(1)
      end
    end

    context 'response' do
      subject { JSON.parse(VueData::Global::ShopMapping.render_json(nil, country_id: country.id))['records'].first.keys }
      it { is_expected.to match_array(%w(id name url_home domain affiliate_networks)) }
    end
  end
end
