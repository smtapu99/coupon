describe CouponCode, :type => :model do

  let(:site) { create :site }
  let(:shop) { create :shop, site: site }
  let(:coupon) { create :coupon, site: site, shop: shop }

  before do
    Site.current = site
    Time.zone = 'UTC'
  end

  describe '.use' do
    let!(:code) { create :coupon_code, coupon: coupon, site: site }

    it 'is expected to change used_at' do
      expect { code.use! }.to change { code.used_at }.from(nil)
    end
  end

  describe '.allowed_import_params' do
    subject { CouponCode.allowed_import_params }
    it { is_expected.to match_array([:coupon_code_id, :coupon_id, :code, :end_date]) }
  end

  describe '.usable' do
    let!(:code1) { create :coupon_code, coupon: coupon, site: site }
    let!(:code2) { create :coupon_code, used_at: Time.now, coupon: coupon, site: site }
    subject { CouponCode.usable }
    it { is_expected.to include(code1) }
    it { is_expected.to_not include(code2) }
  end

  describe '.imported' do
    let!(:code1) { create :coupon_code, is_imported: true, coupon: coupon, site: site }
    let!(:code2) { create :coupon_code, is_imported: false, coupon: coupon, site: site }
    subject { CouponCode.imported }
    it { is_expected.to include(code1) }
    it { is_expected.to_not include(code2) }
  end

  describe '::export' do

    let(:used_at) {{
      "used_at_from(1i)" => "2017",
      "used_at_from(2i)" => "7",
      "used_at_from(3i)" => "4",
      "used_at_from(4i)" => "01",
      "used_at_from(5i)" => "00",
      "used_at_to(1i)" => "2017",
      "used_at_to(2i)" => "8",
      "used_at_to(3i)" => "4",
      "used_at_to(4i)" => "01",
      "used_at_to(5i)" => "00"
    }}
    let(:end_date) {{
      "end_date_from(1i)" => "2017",
      "end_date_from(2i)" => "9",
      "end_date_from(3i)" => "2",
      "end_date_from(4i)" => "00",
      "end_date_from(5i)" => "00",
      "end_date_to(1i)" => "2017",
      "end_date_to(2i)" => "10",
      "end_date_to(3i)" => "3",
      "end_date_to(4i)" => "02",
      "end_date_to(5i)" => "02"
    }}
    let(:creation_date) {{
      "created_at_from(1i)" => Time.zone.now.year,
      "created_at_from(2i)" => Time.zone.now.month,
      "created_at_from(3i)" => Time.zone.now.day,
      "created_at_from(4i)" => Time.zone.now.hour,
      "created_at_from(5i)" => Time.zone.now.min,
      "created_at_to(1i)" => Time.zone.now.year,
      "created_at_to(2i)" => Time.zone.now.month,
      "created_at_to(3i)" => Time.zone.now.day,
      "created_at_to(4i)" => Time.zone.now.hour,
      "created_at_to(5i)" => Time.zone.now.min
    }}
    let(:used_coupon_code) { create :coupon_code, :with_tracking_user, site: site, coupon: coupon, used_at: "2017-08-01 17:38:42" }
    let(:end_date_designated_coupon_code) { create :coupon_code, site: site, coupon: coupon, end_date: "2017-10-01 17:38:42" }
    let(:all_coupon_codes) {[ used_coupon_code, end_date_designated_coupon_code]}

    context 'without optional parameters' do
      subject { CouponCode.export({}) }
      it { is_expected.to match_array(all_coupon_codes) }
    end

    context 'with existing coupon ID' do
      subject { CouponCode.export({ coupon_id: coupon.id }) }
      it { is_expected.to match_array(all_coupon_codes) }
    end

    context 'with non-existing coupon ID' do
      subject { CouponCode.export({ coupon_id: 4 }) }
      it { is_expected.to be_empty }
    end

    context 'with imported flag' do
      subject { CouponCode.export({ is_imported: true }) }
      it { is_expected.to be_empty }
    end

    context 'without imported flag' do
      subject { CouponCode.export({ is_imported: false }) }
      it { is_expected.to match_array(all_coupon_codes) }
    end

    context 'with Used At/From filter' do
      subject { CouponCode.export(used_at) }
      it { is_expected.to match_array([used_coupon_code]) }
    end

    context 'with End Date From/To filter' do
      subject { CouponCode.export(end_date) }
      it { is_expected.to match_array([end_date_designated_coupon_code]) }
    end

    context 'with Created At From/To filter' do
      subject { CouponCode.export(creation_date) }
      it { is_expected.to match_array([used_coupon_code]) }
    end

    context 'with tracking user' do
      subject { CouponCode.export({ tracking_user_id: used_coupon_code.tracking_user.id }) }
      it { is_expected.to match_array([used_coupon_code]) }
    end
  end
end
