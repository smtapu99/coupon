class Tracking::Click::Out < Tracking::Click::Base

  attr_reader :coupon, :site, :request, :params, :cookies

  def initialize(site, coupon, request, params, cookies)
    @site, @coupon, @request, @params, @cookies = site, coupon, request, params, cookies
  end

  private

  def click_params
    {
      site_id: site.id,
      tracking_user_id: current_tracking_user.id,
      coupon_id: coupon.id,
      landing_page: coupon.url,
      referrer: request.referer,
      uniqid: SecureRandom.urlsafe_base64(23),
      click_type: 'click_out'
    }
  end
end
