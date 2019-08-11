require 'carrierwave/test/matchers'

module Admin
  describe CouponUploader do
    include CarrierWave::Test::Matchers

    before do
      CouponUploader.enable_processing = true

      @coupon = Admin::Coupon
      @uploader = CouponUploader.new(@coupon, :logo)
      @uploader.store!(File.open(path_to_file))
    end

    after do
      CouponUploader.enable_processing = false
      @uploader.remove!
    end

    context 'the thumb version' do
      xit "should scale down a landscape image to be exactly 150 by 150 pixels" do
        @uploader.thumb.should have_dimensions(150, 150)
      end
    end
  end
end
