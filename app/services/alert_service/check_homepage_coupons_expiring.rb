class AlertService::CheckHomepageCouponsExpiring

  def self.call(*args)
    new(*args).call
  end

  def call
    widgets.each do |widget|
      expiring_coupons_in_3_days(widget).present? ? create_alert(widget) : clean_alert(widget)
    end
  end

  private

  def widgets
    Widget.where(name: 'featured_coupons', id: WidgetArea.where(site: Site.active, name: 'main').map(&:widget_order).flatten)
  end

  def widget_coupons(widget)
    Coupon.where(id: widget.coupon_ids.gsub(' ', '').split(','))
  end

  def expiring_coupons_in_3_days(widget)
    widget_coupons(widget).where('end_date <= ?', Time.zone.now + 3.days)
  end

  def create_alert(widget)
    alert = Alert.widget_coupons_expiring_3_days.find_or_initialize_by(site_id: widget.site.id, alertable: widget)
    alert.assign_attributes status: 'active', solved_by_id: nil, solved_at: nil, message: alert_message(widget), is_critical: true
    alert.save
    alert
  end

  def clean_alert(widget)
    Alert.widget_coupons_expiring_3_days.where(site_id: widget.site.id, alertable: widget).delete_all
  end

  def alert_message(widget)
    "Widget #{widget.id} in #{widget.campaign_id || 'Home'} has coupons that will be expired in 3 days"
  end
end
