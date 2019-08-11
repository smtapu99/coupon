class AlertService
  ALERT_IF_EMPTY_IN_DAYS = 3.freeze

  def self.check_coupons_expiring
    Site.active.each do |site|
      site.shops.active.by_tier_group(1).each do |shop|
        Time.zone = site.timezone
        count = shop.coupons.active_in_days(ALERT_IF_EMPTY_IN_DAYS).count
        if count > 0
          # resolve existing alerts
          alert = Alert.find_by(site_id: site.id, alertable_id: shop.id, alertable_type: 'Shop', alert_type: 'coupons_expiring')
          alert.touch(:solved_at) if alert.present?
          next
        end

        active_coupons = shop.coupons.active.reorder(end_date: :desc)
        last_active_coupon = active_coupons.last

        Alert.find_or_initialize_by(site_id: site.id, alertable_id: shop.id, alertable_type: 'Shop', alert_type: 'coupons_expiring').tap do |alert|
          alert.status = 'active'
          alert.solved_by_id = nil
          alert.solved_at = nil
          alert.is_critical = true
          if last_active_coupon.present?
            alert.message = "Tier 1 Shop will be empty at #{last_active_coupon.end_date.to_s(:db)}"
          else
            alert.message = 'Tier 1 Shop is already empty'
          end
          alert.save
        end
      end
    end
  end

  def self.check_uniq_codes_empty
    Site.active.each do |site|
      threshold = site.setting.get('alerts.uniq_coupons_threshold', default: 100).to_i
      site.coupons.active.where(use_uniq_codes: true).each do |coupon|
        count = coupon.coupon_codes.usable.count

        if count > threshold
          # resolve existing alerts
          alert = Alert.find_by(site_id: site.id, alertable_id: coupon.id, alertable_type: 'Coupon', alert_type: 'uniq_codes_empty')
          alert.touch(:solved_at) if alert.present?
          next
        end

        Alert.find_or_initialize_by(site_id: site.id, alertable_id: coupon.id, alertable_type: 'Coupon', alert_type: 'uniq_codes_empty').tap do |alert|
          alert.status = 'active'
          alert.solved_by_id = nil
          alert.solved_at = nil
          alert.message = "Only #{count} unique coupon codes left"
          alert.save
        end
      end
    end
  end
end
