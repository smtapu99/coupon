describe AlertService::CheckHomepageCouponsExpiring do

  let!(:site) { create :site, hostname: 'test.host' }
  let!(:coupons_1) { create_list :long_term_coupon, 3, site: site}
  let!(:coupons_2) { create_list :long_term_coupon, 3, site: site}
  let!(:coupons_3) { create_list :long_term_coupon, 3, site: site}
  let!(:widget_1) {
    create :featured_coupons_widget, site: site, value: OpenStruct.new(coupon_ids: coupons_1.map(&:id).join(','))
  }
  let!(:widget_2) {
    create :featured_coupons_widget, site: site, value: OpenStruct.new(coupon_ids: coupons_2.map(&:id).join(','))
  }
  let!(:widget_3) {
    create :featured_coupons_widget, site: site, value: OpenStruct.new(coupon_ids: coupons_3.map(&:id).join(','))
  }
  let(:widget_area_widgets) {[widget_1, widget_2]}
  let!(:main_widget_area) { create :widget_area, site: site, value: OpenStruct.new(widget_order: [widget_area_widgets.map(&:id).map(&:to_s)]) }

  let!(:check_homepage_coupons_expiring) { AlertService::CheckHomepageCouponsExpiring.new }

  context '#call' do
    subject { check_homepage_coupons_expiring.call }

    context 'when site has coupons expiring in 3 days' do
      before { coupons_1.first.update(end_date: (Time.zone.now + 3.days)) }

      it 'create widget_coupons_expiring_3_days alert' do
        expect{ subject }.to change { Alert.widget_coupons_expiring_3_days.count }.by(1)
      end
    end

    context 'when coupons expired' do
      let(:valid_attributes) {
        {
          status: 'active',
          solved_by_id: nil,
          solved_at: nil,
          site_id: widget_1.site.id,
          alertable_id: widget_1.id,
          alertable_type: 'WidgetBase',
          alert_type: Alert.alert_types[:widget_coupons_expiring_3_days],
          message: check_homepage_coupons_expiring.send(:alert_message, widget_1)
        }
      }
      let(:alerts_count) { 3 }

      before do
        create_list(:alert, alerts_count, valid_attributes)
        check_homepage_coupons_expiring.call
      end

      it { expect(Alert.widget_coupons_expiring_3_days).to be_empty }
    end
  end

  context '#widgets' do
    subject { check_homepage_coupons_expiring.send(:widgets) }

    context 'when Site active' do

      it 'return widgets for main_widget_area' do
        expect(subject.to_a).to eq(widget_area_widgets)
      end

      it 'return featured_coupons widgets' do
        expect(subject.map(&:name).uniq).to eq(widget_area_widgets.map(&:name).uniq)
      end
    end

    context 'when Site inactive' do
      before {site.update status: 'inactive'}

      it 'widgets should be empty' do
        is_expected.to be_empty
      end
    end
  end

  context '#widget_coupons' do
    subject { check_homepage_coupons_expiring.send(:widget_coupons, widget_1) }

    it 'return coupon for widget' do
      expect(subject.ids).to eq(coupons_1.map(&:id))
    end
  end

  context '#expiring_coupons_in_3_days' do
    subject { check_homepage_coupons_expiring.send(:expiring_coupons_in_3_days, widget_1) }

    context 'when widget has coupons expire in 3 days' do
      before { coupons_1.first.update(end_date: (Time.zone.now + 2.days)) }
      before { coupons_1.last.update(end_date: (Time.zone.now + 4.days)) }

      it 'return widget coupons expire in 3 days' do
        is_expected.not_to be_empty
        expect(subject.map(&:end_date)).to all( be < Time.zone.now + 3.days )
      end
    end

    context 'when widget has no coupons expire in 3 days' do
      before { coupons_1.last.update(end_date: (Time.zone.now + 5.days)) }

      it { is_expected.to be_empty }
    end
  end

  context '#create_alert' do
    let(:valid_attributes) {
      {
        status: 'active',
        solved_by_id: nil,
        solved_at: nil,
        site_id: widget_1.site.id,
        alertable_id: widget_1.id,
        alertable_type: 'WidgetBase',
        alert_type: Alert.alert_types[:widget_coupons_expiring_3_days],
        message: check_homepage_coupons_expiring.send(:alert_message, widget_1)
      }
    }

    subject { check_homepage_coupons_expiring.send(:create_alert, widget_1) }

    it { expect{ subject }.to change { Alert.widget_coupons_expiring_3_days.count }.by(1) }
    it { is_expected.to have_attributes(valid_attributes) }

    context 'when alert already exist' do
      before do
        coupons_1.first.update(end_date: (Time.zone.now + 3.days))
        create(:alert, valid_attributes)
      end

      it 'create widget_coupons_expiring_3_days alert' do
        expect{ subject }.to change { Alert.widget_coupons_expiring_3_days.count }.by(0)
      end
    end
  end

  context '#clean_alert' do
    let(:valid_attributes) {
      {
        status: 'active',
        solved_by_id: nil,
        solved_at: nil,
        site_id: widget_1.site.id,
        alertable: widget_1,
        alert_type: Alert.alert_types[:widget_coupons_expiring_3_days],
        message: check_homepage_coupons_expiring.send(:alert_message, widget_1)
      }
    }
    let(:alerts_count) { 3 }

    before { create_list(:alert, alerts_count, valid_attributes) }

    subject { check_homepage_coupons_expiring.send(:clean_alert, widget_1) }

    it 'clear all alerts for this type' do
      expect{ subject }.to change { Alert.widget_coupons_expiring_3_days.count }.by(-alerts_count)
      expect(Alert.widget_coupons_expiring_3_days.where(valid_attributes.slice(:site_id, :alertable))).to be_empty
    end
  end

  context '#alert_message' do
    let(:valid_message) { "Widget #{widget_1.id} in #{widget_1.campaign_id || 'Home'} has coupons that will be expired in 3 days" }

    subject { check_homepage_coupons_expiring.send(:alert_message, widget_1) }

    context 'when 3 days alert' do
      it 'return valid type' do
        is_expected.to eq(valid_message)
      end
    end
  end
end
