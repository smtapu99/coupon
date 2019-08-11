describe ExpiredExclusive, type: :model do

  let!(:site) { create :site, time_zone: 'UTC' }
  let!(:coupons) { create_list :coupon, 2, site: site, is_exclusive: true }

  before { Time.zone = 'UTC' }

  it 'validates presence of end_date' do
    ee = ExpiredExclusive.new({ coupon_ids: coupons.map(&:id) })
    expect(ee).to_not be_valid
  end

  it 'validates coupons_valid' do
    ee = ExpiredExclusive.new({ coupon_ids: coupons.map(&:id), end_date: (Time.zone.now - 1.year).utc.to_date.to_s(:db) })
    expect(ee).to_not be_valid
  end

  context '::solve' do
    it 'returns false unless coupons are present' do
      new_date = (Time.zone.now + 1.year).end_of_day.utc
      ee = ExpiredExclusive.new({ coupon_ids: [99999999], end_date: new_date.to_date.to_s(:db), status: 'blocked' })
      expect(ee.solve).to eq(false)
    end

    it 'changes status and end_date on coupon_ids' do
      new_date = (Time.zone.now + 1.year).end_of_day.utc
      ee = ExpiredExclusive.new({ coupon_ids: coupons.map(&:id), end_date: new_date.to_date.to_s(:db), status: 'blocked' })
      expect(ee.solve).to be_truthy

      expect(coupons.first.reload.end_date.utc.to_date).to eq(new_date.utc.to_date)
      expect(coupons.first.reload.status).to eq('blocked')
    end
  end
end
