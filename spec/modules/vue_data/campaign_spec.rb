describe VueData::Campaign do
  let(:site) { create :site }
  let(:another_site) { create :site }

  context '::render_json' do
    let!(:campaigns) { create_list :campaign, 2, site: site}
    let!(:another_campaigns) { create_list :campaign, 3, site: another_site}

    context 'succeeds' do
      it 'with single site' do
        expect(JSON.parse(VueData::Campaign.render_json(site.id))['count']).to eq(campaigns.count)
      end

      it 'with multiple sites' do
        expect(JSON.parse(VueData::Campaign.render_json([site.id, another_site.id]))['count']).to eq(Campaign.count)
      end

      it 'with order by parent' do
        expect(JSON.parse(VueData::Campaign.render_json(site.id, order: 'parent', direction: 'asc'))['count']).to eq(campaigns.count)
      end

      it 'with order by shop' do
        expect(JSON.parse(VueData::Campaign.render_json(site.id, order: 'shop', direction: 'asc'))['count']).to eq(campaigns.count)
      end
    end

    context 'returns' do
      subject { JSON.parse(VueData::Campaign.render_json(site.id))['records'].first.keys }

      it { is_expected.to match_array(%w(id status is_root_campaign name slug shop blog_feed_url start_date end_date parent)) }
    end
  end
end
