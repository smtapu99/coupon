describe VueData::Tag do
  context '::render_json' do
    let(:site) { create :site }
    let!(:tags) { create_list :tag, 2, site: site }

    before { Site.current = site }

    context 'succeeds' do
      it 'returns tags' do
        expect(JSON.parse(VueData::Tag.render_json(site.id))['count']).to eq(tags.count)
      end

      it 'when sort by word' do
        expect(JSON.parse(VueData::Tag.render_json(site.id, order: 'word', direction: 'asc'))['count']).to eq(tags.count)
      end

      it 'when sort by category' do
        expect(JSON.parse(VueData::Tag.render_json(site.id, order: 'category', direction: 'asc'))['count']).to eq(tags.count)
      end
    end

    context 'returns' do
      subject { JSON.parse(VueData::Tag.render_json(nil))['records'].first.keys }

      it { is_expected.to match_array(%w(id word category is_blacklisted api_hits)) }
    end
  end
end
