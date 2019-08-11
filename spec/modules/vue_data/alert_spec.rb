describe VueData::Alert do
  context '::render_json' do
    let(:site) { create :site }
    let!(:alerts) { create_list :alert, 2, site: site }

    before { Site.current = site }

    context 'succeeds' do
      it 'returns alerts' do
        expect(JSON.parse(VueData::Alert.render_json(nil))['count']).to eq(alerts.count)
      end

      it 'when sort by model' do
        expect(JSON.parse(VueData::Alert.render_json(site.id, order: 'model', direction: 'asc'))['count']).to eq(alerts.count)
      end

      it 'when sort by date' do
        expect(JSON.parse(VueData::Alert.render_json(site.id, order: 'date', direction: 'asc'))['count']).to eq(alerts.count)
      end

      it 'when sort by model_id' do
        expect(JSON.parse(VueData::Alert.render_json(site.id, order: 'model_id', direction: 'asc'))['count']).to eq(alerts.count)
      end
    end

    context 'returns' do
      subject { JSON.parse(VueData::Alert.render_json(nil))['records'].first.keys }

      it { is_expected.to match_array(%w(id is_critical edit_path status alert_type type model model_id message date)) }
    end
  end
end
