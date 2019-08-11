describe TrackingClick, type: :model do
  context '::colums' do
    subject { TrackingClick.columns }
    it { is_expected.to_not include('page_type') }
  end

  context '::click_out' do
    let!(:click) { create :tracking_click, click_type: 'click_out' }
    let!(:other_click) { create :tracking_click, click_type: 'click_in' }
    subject { TrackingClick.click_out }
    it { is_expected.to eq([click]) }
  end

  context '::click_in' do
    let!(:click) { create :tracking_click, click_type: 'click_in' }
    let!(:other_click) { create :tracking_click, click_type: 'click_out' }
    subject { TrackingClick.click_in }
    it { is_expected.to eq([click]) }
  end

  context '::with_uniqid' do
    let!(:click) { create :tracking_click, uniqid: '12345' }
    let!(:other_click) { create :tracking_click, uniqid: nil }
    subject { TrackingClick.with_uniqid }
    it { is_expected.to eq([click]) }
  end

  context 'TruncateReferrer truncates referrer to 255 chars' do
    let!(:click) { create :tracking_click, referrer: 'n' * 300 }
    subject { click.referrer.length }
    it { is_expected.to eq(255) }
  end
end
