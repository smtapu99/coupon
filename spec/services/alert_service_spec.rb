describe AlertService do
  let!(:site) { create :site }

  context 'alerts:check_coupons_expiring' do
    let!(:shop) { create :shop, tier_group: 1 }
    let!(:other_shop) { create :shop, tier_group: 1 }
    let!(:unexpired) { create :coupon, shop: shop, end_date: Time.zone.now + 5.days }
    let!(:will_expire) { create :coupon, shop: other_shop, end_date: Time.zone.now + 1.day }

    it 'runs gracefully without active coupons' do
      expect { AlertService.check_coupons_expiring }.not_to raise_error
    end

    it 'creates Alert only on Tier 1 Shops' do
      Shop.update_all(tier_group: 2)
      AlertService.check_coupons_expiring

      expect(Alert.count).to eq(0)
    end

    it 'creates Alert if Shop is empty' do
      Coupon.update_all(status: 'blocked')
      AlertService.check_coupons_expiring
      expect(Alert.count).to eq(2)
      expect(Alert.first.message).to eq('Tier 1 Shop is already empty')
    end

    it 'creates Alert if Coupons expire within 3 days' do
      AlertService.check_coupons_expiring

      expect(Alert.count).to eq(1)

      alert = Alert.first
      expect(alert.message).to eq('Tier 1 Shop will be empty at ' + will_expire.end_date.to_s(:db))
      expect(alert.site_id).to eq(site.id)
      expect(alert.alertable_type).to eq('Shop')
      expect(alert.alert_type).to eq('coupons_expiring')
      expect(alert.status).to eq('active')
    end

    context 'when alert reason doesnt exist anymore' do
      let!(:alert) { create :alert, alert_type: 'coupons_expiring', alertable_type: 'Shop', alertable_id: shop.id, site_id: site.id }

      it 'resolves the alert' do
        AlertService.check_coupons_expiring
        expect(alert.reload.solved_at).to_not eq(nil)
      end
    end
  end

  context 'alerts:check_uniq_codes_empty' do
    let!(:setting) { create :setting, site: site, alert: { uniq_coupons_threshold: 5 } }

    it 'runs gracefully without active coupons' do
      expect { AlertService.check_uniq_codes_empty }.not_to raise_error
    end

    context 'with active uniq coupons' do
      let!(:coupon) { create :coupon, site: site, use_uniq_codes: true }
      let!(:codes) { create_list :coupon_code, 4, site: site, coupon: coupon }

      it 'creates an Alert if count uniq codes below threshold' do
        AlertService.check_uniq_codes_empty

        alert = Alert.first
        expect(alert).to be_a(Alert)
        expect(alert.message).to eq('Only 4 unique coupon codes left')
        expect(alert.site_id).to eq(site.id)
        expect(alert.alertable_type).to eq('Coupon')
        expect(alert.alert_type).to eq('uniq_codes_empty')
        expect(alert.status).to eq('active')
      end

      context 'when alert reason doesnt exist anymore' do
        let!(:alert) { create :alert, alert_type: 'uniq_codes_empty', alertable_type: 'Coupon', alertable_id: coupon.id, site_id: site.id }
        let!(:codes) { create_list :coupon_code, 200, site: site, coupon: coupon }

        it 'resolves the alert' do
          AlertService.check_uniq_codes_empty
          expect(alert.reload.solved_at).to_not eq(nil)
        end
      end
    end
  end
end
