# ClickoutUrlService
# takes a coupon and manual clickrefs as input and returns a clickout_url
# which in some cases might get optimized by ClickoutUrl::StandardUrl and its child
# classes.
class ClickoutUrlService
  # Initialices a ClickUrlService
  # @param coupon [Object] Coupon with valid :url attriute
  # @param manual_clickrefs [Hash] allows manual clickrefs coming from the controller. Might be wanted
  #   to add page specific clickrefs to the url. the clickref must be whitelisted by the adaptor class
  #   in most cases.
  def initialize(coupon, manual_clickrefs={})
    raise ClickoutUrlServiceError.new('Invalid Coupon URL') unless coupon.url.present?

    @coupon = coupon
    @manual_clickrefs = manual_clickrefs
  end

  # optimizes the clickout url of the coupon
  # @return [String] optimized url or in case of any errors returns the initial url as fallback
  #   to be sure users can still clickout
  def url
    begin
      adaptor_class.new(@coupon, @manual_clickrefs).add_tracking
    rescue Exception
      @coupon.url
    end
  end

  def replace_tracking_click(tc_id)
    url.gsub(/(mt_tracking|pc_tracking|pctracking)/, tc_id.to_s).gsub("\302\240", ' ').strip
  end

  private

  def adaptor_class
    if @coupon.url.match(/^(http|https)\:\/\/www.awin1/i)
      ClickoutUrl::AwinUrl
    elsif @coupon.url.match(/digidip/i)
      ClickoutUrl::DigidipUrl
    else
      ClickoutUrl::StandardUrl
    end
  end
end

class ClickoutUrlServiceError < StandardError
end
