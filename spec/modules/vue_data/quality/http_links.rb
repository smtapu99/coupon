describe VueData::Quality::HttpLinks do
  let(:site) { create :site }

  context '::render_json' do
    before { Site.current = site }

    let(:hdoc) { create :html_document, content: "test http://#{Site.current.hostname}" }
    let!(:shop) { create :shop, site: site, html_document: hdoc }

    context 'succeeds' do
      subject { JSON.parse(VueData::Quality::HttpLinks.render_json(site.id))['count'] }

      it { is_expected.to eq(1)}
    end

    context 'returns' do
      subject { JSON.parse(VueData::Quality::HttpLinks.render_json(site.id))['records'].first.keys }

      it { is_expected.to match_array(%w(object_id object_type message)) }
    end
  end
end
