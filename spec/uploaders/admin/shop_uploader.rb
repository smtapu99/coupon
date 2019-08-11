require "spec_helper"
require 'carrierwave/test/matchers'

module Admin
  describe ShopUploader do
    include CarrierWave::Test::Matchers

    before do
      ShopUploader.enable_processing = true

      @shop = Admin::Shop
      @uploader = ShopUploader.new(@shop, :logo)
      @uploader.store!(File.open(path_to_file))
    end

    after do
      ShopUploader.enable_processing = false
      @uploader.remove!
    end

    context 'the thumb version' do
      xit "should scale down a landscape image to be exactly 150 by 150 pixels" do
        @uploader.thumb.should have_dimensions(150, 150)
      end
    end

    # context 'the small version' do
    #   it "should scale down a landscape image to fit within 200 by 200 pixels" do
    #     @uploader.small.should be_no_larger_than(200, 200)
    #   end
    # end

    # it "should make the image readable only to the owner and not executable" do
    #   @uploader.should have_permissions(0600)
    # end
  end
end
