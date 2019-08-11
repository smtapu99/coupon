describe VueData::RedirectRule do
  let(:site) { create :site , hostname: 'www.example.com' }

  context '::render_json' do
    let!(:redirect_rule_1) { create :redirect_rule, source: '/foo', :destination => '/foo.html', site_id: site.id }
    let!(:redirect_rule_2) { create :redirect_rule, source: '/bar', :destination => '/bar.html', site_id: site.id }

    context 'succeeds' do
      it 'returns redirect rules' do
        expect(JSON.parse(VueData::RedirectRule.render_json(site.id))['count']).to eq(RedirectRule.count)
      end

    end

    context 'returns' do
      subject { JSON.parse(VueData::RedirectRule.render_json(site.id))['records'].first.keys }

      it { is_expected.to match_array(%w(id active source destination)) }
    end
  end
end
