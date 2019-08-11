describe VueData::Shop do
  let(:site) { create :site }
  let(:another_site) { create :site }

  context '::render_json' do
    let!(:shops) { create_list :shop, 2, site_id: site.id }
    let!(:other_shops) { create_list :shop, 3, site: another_site }

    context 'succeeds' do
      it 'with single site' do
        expect(JSON.parse(VueData::Shop.render_json(site.id))['count']).to eq(shops.count)
      end

      it 'with multiple sites' do
        expect(JSON.parse(VueData::Shop.render_json([site.id, another_site.id]))['count']).to eq(Shop.count)
      end
    end

    context 'returns' do
      subject { JSON.parse(VueData::Shop.render_json(site.id))['records'].first.keys }

      it { is_expected.to match_array(%w(id status tier_group title slug is_top is_hidden priority_score updated_at)) }
    end
  end
end
