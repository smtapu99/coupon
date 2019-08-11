module SummaryHelper

  class BestCollector
    KEYS = [:top, :percentage, :currency, :free_delivery, :last_updated]
    attr_accessor(*KEYS)

    def keys
      KEYS
    end

    def coupon(key)
      instance_variable_get("@#{key}")
    end

    def discount
      @discount ||= [percentage_saving, currency_saving].reject(&:blank?).first
    end

    private

    def percentage_saving
      @percentage.try(:savings_in_string, false)
    end

    def currency_saving
      @currency.try(:savings_in_string, false)
    end
  end

  class CountCollector
    KEYS = [:coupon, :offer, :exclusive, :editors_pick, :free_delivery, :total]

    attr_accessor(*KEYS)

    def initialize(opts = {})
      KEYS.except(:total).each do |key|
        instance_variable_set(var_name(key), OpenStruct.new(count: 0, coupon: nil))
      end
      @total = OpenStruct.new(count: 0)
    end

    def keys
      KEYS
    end

    def increment(key)
      var(key).count += 1
    end

    def set_coupon(key, coupon)
      var(key).coupon = coupon
    end

    def coupon(key)
      var(key).coupon
    end

    def count(key)
      var(key).count
    end

    def value_of_interest?(key)
      return var(key).count > 0 if key.to_sym == :total
      var(key).count > 0 && var(key).coupon.present?
    end

    private

    def var(key)
      instance_variable_get(var_name(key))
    end

    def var_name(key)
      "@#{key}"
    end
  end

  def render_summary_widget(record, opts = {})
    return unless @coupons.present?

    setting = opts[:secondary].present? ? 'secondary_summary_widget' : 'summary_widget'
    type = Setting::get("publisher_site.#{setting}", default: nil)
    return unless type.present?

    locals = {
      coupons: @coupons,
      without_h2: opts[:without_h2].present?,
      title: record.is_a?(Shop) ? record.title : record.name
    }

    locals[:best] = summary(:best) if needs_best?(type)
    locals[:counts] = summary(:counts) if needs_counts?(type)

    return if needs_best?(type) && !locals[:best].present?
    return if needs_counts?(type) && !locals[:counts].present?

    if ['best_deals_summary_advanced', 'best_deals_summary_advanced_code'].include?(type)
      locals[:with_code] = type == 'best_deals_summary_advanced_code'
      render partial: 'widgets/summary_widgets/best_deals_summary_advanced', locals: locals
    else
      render partial: "widgets/summary_widgets/#{type}", locals: locals
    end
  end

  def anchorize_title(content, anchor)
    return content unless Setting::get('publisher_site.anchors_for_summary_widget', default: 0).to_i == 1
    content_tag(:a, href: anchor) do
      content
    end
  end

  def summary(type)
    instance_variable_get("@#{type}")
  end

  def summarize_coupons(coupon, index)
    @best ||= BestCollector.new
    @counts ||= CountCollector.new

    CountCollector::KEYS.except(:total).each do |key|
      @counts.increment(key) if coupon.send("is_#{key}?")
      @counts.set_coupon(key, coupon) if send("is_best_#{key}?", coupon)
    end

    @counts.increment(:total)

    @best.last_updated = coupon if is_last_updated_coupon?(coupon)
    @best.top = coupon and return if index == 0
    @best.percentage = coupon and return if is_best_percentage_coupon?(coupon)
    @best.currency = coupon and return if is_best_currency_coupon?(coupon)
    @best.free_delivery = coupon and return if is_free_delivery_coupon?(coupon)
  end

  def localize_end_date(datetime)
    if datetime < Time.zone.now + 24.hours
      humanize_time_ahead(datetime)
    else
      I18n.l(datetime.to_date, format: :short)
    end
  end

  def localize_updated_at(datetime)
    if datetime > Time.zone.now - 24.hours
      humanize_time_ago(datetime)
    else
      I18n.l(datetime.to_date, format: :short)
    end
  end

  def humanize_time_ago(from_time, options = {})
    current_scope, I18n.global_scope = I18n.global_scope, :backend
    result = I18n.t('datetime.distance_with_ago', distance: time_ago_in_words(from_time, options))
    I18n.global_scope = current_scope
    result
  end

  def humanize_time_ahead(in_time, options={})
    current_scope, I18n.global_scope = I18n.global_scope, :backend
    result = time_ago_in_words(in_time, locale: I18n.locale)
    I18n.global_scope = current_scope
    result
  end

  def summarize_coupons_advanced(coupons)
    return [] unless coupons.present?

    remove_ids = []
    summary = []
    groups = {}
    max = 7

    last_updated_coupon = coupons.sort_by(&:updated_at).last

    # Top Coupon
    summary = [coupons.first]
    remove_ids << summary.first.id

    # Percentage
    [:percentage, :currency].each do |type|
      groups[type] = coupons.select(&:"is_#{type}?")
        .reject { |c| remove_ids.include?(c.id) }
        .sort_by { |c| c.savings.to_i }
        .reverse
        .first(max - 1)
      remove_ids += groups[type].map(&:id)
    end

    # without_savings
    groups[:without_savings] = coupons
      .reject { |c| remove_ids.include?(c.id) }
      .select { |c| c.savings.to_i == 0 }
      .first(max - 1)
    remove_ids += groups[:without_savings].map(&:id)

    i = 0
    while summary.size < max && i <= 3
      [:percentage, :currency, :without_savings].each do |type|
        summary += groups[type].shift(2)
      end
      i += 1
    end

    summary = summary.take(max)
    summary << last_updated_coupon.updated_at
    summary
  end

  private

  def needs_counts?(type)
    ['coupons_summary', 'best_deals_and_coupons_summary'].include?(type.to_s)
  end

  def needs_best?(type)
    ['best_deals_summary', 'best_deals_and_coupons_summary'].include?(type.to_s)
  end

  def is_best_coupon?(coupon)
    return false unless coupon.is_coupon?
    @counts.coupon(:coupon).blank? || coupon.savings.to_i > 0 && coupon.savings.to_i > @counts.coupon(:coupon).savings.to_i
  end

  def is_best_offer?(coupon)
    return false unless coupon.is_offer?
    @counts.coupon(:offer).blank? || coupon.savings.to_i > 0 && coupon.savings.to_i > @counts.coupon(:offer).savings.to_i
  end

  def is_best_exclusive?(coupon)
    return false unless coupon.is_exclusive?
    @counts.coupon(:exclusive).blank? || coupon.savings.to_i > 0 && coupon.savings.to_i > @counts.coupon(:exclusive).savings.to_i
  end

  def is_best_editors_pick?(coupon)
    return false unless coupon.is_editors_pick?
    @counts.coupon(:editors_pick).blank? || coupon.savings.to_i > 0 && coupon.savings.to_i > @counts.coupon(:editors_pick).savings.to_i
  end

  def is_best_free_delivery?(coupon)
    return false unless coupon.is_free_delivery?
    @counts.coupon(:free_delivery).blank? || coupon.savings.to_i > 0 && coupon.savings.to_i > @counts.coupon(:free_delivery).savings.to_i
  end

  def is_best_percentage_coupon?(coupon)
    return false if coupon.savings_in != 'percent' || coupon.savings.to_i == 0

    @best.percentage.nil? || coupon.savings.to_i > @best.percentage.savings.to_i
  end

  def is_best_currency_coupon?(coupon)
    return false if coupon.savings_in != 'currency' || coupon.savings.to_i == 0

    @best.currency.nil? || coupon.savings.to_i > @best.currency.savings.to_i
  end

  def is_free_delivery_coupon?(coupon)
    return false if coupon.savings.to_i == 0

    @best.free_delivery.nil? || coupon.savings.to_i > @best.free_delivery.savings.to_i
  end

  def is_last_updated_coupon?(coupon)
    @best.last_updated.nil? || coupon.updated_at > @best.last_updated.updated_at
  end
end
