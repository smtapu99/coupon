describe VueData::Category do
  let(:site) { create :site }
  let(:another_site) { create :site }

  context '::render_json' do
    let!(:categories) { create_list :category, 2, site: site}
    let!(:another_categories) { create_list :category, 3, site: another_site}

    context 'succeeds' do
      it 'with single site' do
        expect(JSON.parse(VueData::Category.render_json(site.id))['count']).to eq(categories.count)
      end

      it 'with multiple sites' do
        expect(JSON.parse(VueData::Category.render_json([site.id, another_site.id]))['count']).to eq(Category.count)
      end

      it 'with order by parent' do
        expect(JSON.parse(VueData::Category.render_json(site.id, order: 'parent', direction: 'asc'))['count']).to eq(categories.count)
      end

    end

    context 'returns' do
      subject { JSON.parse(VueData::Category.render_json(site.id))['records'].first.keys }

      it { is_expected.to match_array(%w(id status name slug main_category parent)) }
    end
  end
end
