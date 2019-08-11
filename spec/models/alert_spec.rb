describe Alert, type: :model do
  let!(:site) { create :site }

  it 'has a valid factory' do
    expect(FactoryGirl.create(:alert)).to be_valid
  end

  context '::alert_types' do
    subject { Alert.alert_types }
    it do
      is_expected.to match_array([
        ['uniq_codes_empty', 'uniq_codes_empty'],
        ['coupons_expiring', 'coupons_expiring'],
        ['widget_coupons_expiring_3_days', 'widget_coupons_expiring_3_days']
      ])
    end
  end

  context '::statuses' do
    subject { Alert.statuses }
    it { is_expected.to match_array([['active', 'active'], ['inactive', 'inactive']]) }
  end

  describe '::grid_filter' do
    let!(:another_site) { create :site }
    let!(:alerts) { create_list :alert, 2, site: site, message: 'yes', alertable_id: 1, alertable_type: 'Coupon' }
    let!(:other_alerts) { create_list :alert, 3, site: another_site, alertable_id: 2, alertable_type: 'Shop' }

    it 'filters by id' do
      expect(Alert.grid_filter(id: Alert.first.id)).to match_array(Alert.first)
    end

    it 'filters by model' do
      expect(Alert.grid_filter(model: 'Coupon')).to match_array(alerts)
    end

    it 'filters by model_id' do
      expect(Alert.grid_filter(model_id: 1)).to match_array(alerts)
    end

    it 'filters by message' do
      expect(Alert.grid_filter(message: 'yes')).to match_array(alerts)
    end

    context 'without site_id' do
      it 'returns all alerts' do
        expect(Alert.grid_filter({})).to match_array(Alert.all)
      end
    end
  end

  context '.edit_path' do
    let(:alert) { create :alert }
    subject { alert.edit_path }
    it { is_expected.to eq("/pcadmin/coupons/#{alert.alertable_id}/coupon_codes") }
  end
end
