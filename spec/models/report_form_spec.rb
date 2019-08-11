describe ReportForm, :type => :model do
  let(:site) { create :site }
  let(:report_form) { build :report_form }

  before do
    Site.current = site
    Time.zone = 'UTC'
  end

  describe '#factory' do
    it "has a valid factory" do
        expect(build :report_form).to be_valid
    end
  end

  describe '#attributes' do
    it "should include all attributes" do
      expect(report_form).to have_attributes(:name => "Test", :email => 'test@test.com')
    end

    it "is not valid without a name" do
      report_form = build :report_form, name: nil
      expect(report_form).to_not be_valid
    end

    it "is not valid without a email" do
      report_form = build :report_form, email: nil
      expect(report_form).to_not be_valid
    end

    it "is valid without a shopname" do
      report_form = build :report_form, shopname: nil
      expect(report_form).to be_valid
    end

    it "is valid without a discount" do
      report_form = build :report_form, discount: nil
      expect(report_form).to be_valid
    end

    it "is valid without a link_to_offer" do
      report_form = build :report_form, link_to_offer: nil
      expect(report_form).to be_valid
    end

    it "is valid without a remark" do
      report_form = build :report_form, remark: nil
      expect(report_form).to be_valid
    end

    it "requires an valid email" do
      report_form = build :report_form, email: "test@test.com"
      expect(report_form).to be_valid
    end

    it "invalid email" do
      report_form = build :report_form, email: "test.test.com"
      expect(report_form).to_not be_valid
    end
  end

  describe '#headers' do
    it "should declare appropriate email headers" do
      expect(report_form.headers).to include(:from, :reply_to, :subject, :to)
    end
  end
end
