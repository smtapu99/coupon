describe ShopHelper do
  let!(:simple_coupons) { create_list :coupon, 2 }
  let!(:exclusive_coupons) { create_list :coupon, 2, is_exclusive: true }
  let!(:editors_pick_coupons) { create_list :coupon, 2, is_editors_pick: true }

  context '.shop_exclusive_coupon' do

    it 'returns nothing' do
      simple_coupons = Coupon.where(is_exclusive: false)
      expect(shop_exclusive_coupon(simple_coupons)).to be(nil)
    end

    it 'returns exclusive coupon' do
      exclusive_coupons = Coupon.where(is_exclusive: true)
      expect(shop_exclusive_coupon(exclusive_coupons)).to eq(exclusive_coupons.first)
    end
  end

  context '.shop_editors_pick_coupon' do

    it 'returns nothing' do
      simple_coupons = Coupon.where(is_exclusive: false)
      expect(shop_exclusive_coupon(simple_coupons)).to be(nil)
    end

    it 'returns exclusive coupon' do
      editors_pick_coupons = Coupon.where(is_exclusive: true)
      expect(shop_exclusive_coupon(editors_pick_coupons)).to eq(editors_pick_coupons.first)
    end
  end
end
