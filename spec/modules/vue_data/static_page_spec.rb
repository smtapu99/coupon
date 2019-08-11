describe VueData::StaticPage do
  let(:site) { create :site }
  let(:another_site) { create :site }

  context '::render_json' do
    let!(:static_pages) { create_list :static_page, 2, site: site }
    let!(:another_static_pages) { create_list :static_page, 3, site: another_site }

    context 'succeeds' do
      it 'with single site' do
        expect(JSON.parse(VueData::StaticPage.render_json(site.id))['count']).to eq(static_pages.count)
      end

      it 'with multiple site' do
        expect(JSON.parse(VueData::StaticPage.render_json([site.id, another_site.id]))['count']).to eq(StaticPage.count)
      end

      it 'with order by site' do
        expect(JSON.parse(VueData::StaticPage.render_json(site.id, order: 'site', direction: 'asc'))['count']).to eq(static_pages.count)
      end

    end

    context 'returns' do
      subject { JSON.parse(VueData::StaticPage.render_json(site.id))['records'].first.keys }

      it { is_expected.to match_array(%w(id status site title slug)) }
    end
  end
end
