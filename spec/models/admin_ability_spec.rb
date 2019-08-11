require 'cancan/matchers'

describe AdminAbility do
  let(:user) { nil }
  let(:countries) { [create(:country)] }
  let(:sites) { [create(:site, country: countries.first)] }

  subject(:ability) { AdminAbility.new(user) }

  it 'abilities that are missing are a "cannot" rule' do
    expect(AdminAbility.new(create(:freelancer, sites: sites))).to_not be_able_to :manage, Site.new
  end

  context 'restrict_site_access' do
    let!(:user) { create(:regional_manager, countries: countries) }
    let!(:another_site) { create :site, country: create(:country) }

    let!(:category) { create :category, site_id: sites.first.id }
    let!(:another_category) { create :category, site_id: another_site.id }

    context 'revokes previosly given access if the site_ids dont match' do
      it { is_expected.to be_able_to :manage, category }
      it { is_expected.to_not be_able_to :manage, another_category }
    end
  end

  context 'super_admin' do
    let(:user) { create(:super_admin, id: 1, countries: countries) }
    before { user.update_attribute(:id, 1) }
    it { is_expected.to be_able_to(:manage, :all) }
  end

  context 'admin' do
    let(:user) { create(:admin, countries: countries) }
    before { user.update_attribute(:id, 9999) }
    it { is_expected.to be_able_to(:manage, :all) }
    it { is_expected.to be_able_to(:manage, Global.new) }
    it { is_expected.to be_able_to :change_status, Category.new }

    it { is_expected.to_not be_able_to(:reset_votes, Shop.new) }
  end

  context 'regional_manager' do
    let(:user) { create(:regional_manager, countries: countries) }

    it { is_expected.to_not be_able_to :manage, AffiliateNetwork.new }
    it { is_expected.to be_able_to :manage, Alert.new }
    it { is_expected.to be_able_to :manage, Banner.new }
    it { is_expected.to be_able_to :manage, Campaign.new }
    it { is_expected.to be_able_to :manage, CampaignImport.new }
    it { is_expected.to be_able_to :manage, Category.new }
    it { is_expected.to be_able_to :manage, Coupon.new }
    it { is_expected.to be_able_to :manage, CouponCode.new }
    it { is_expected.to be_able_to :manage, CouponCodeImport.new }
    it { is_expected.to be_able_to :manage, CouponImport.new }
    it { is_expected.to be_able_to :manage, CsvExport.new }
    it { is_expected.to be_able_to :manage, Medium.new }
    it { is_expected.to be_able_to :manage, Setting.new }
    it { is_expected.to be_able_to :manage, Shop.new }
    it { is_expected.to be_able_to :manage, ShopImport.new }
    it { is_expected.to be_able_to :manage, StaticPage.new }
    it { is_expected.to be_able_to :manage, Translation.new }
    it { is_expected.to be_able_to :manage, User.new }
    it { is_expected.to be_able_to :manage, Widget.new }
    it { is_expected.to be_able_to :manage, AwinMigration.new }

    it { is_expected.to be_able_to :read, Country.new }
    it { is_expected.to be_able_to :read, Global.new }
    it { is_expected.to be_able_to :read, RedirectRule.new }
    it { is_expected.to be_able_to :read, Site.new }
    it { is_expected.to be_able_to :read, :quality }
    it { is_expected.to be_able_to :read, AffiliateNetwork.new }

    it { is_expected.to be_able_to :change_status, User.new }
    it { is_expected.to be_able_to :synch_keywords, Shop.new }

    it { is_expected.to_not be_able_to :change_status, Category.new }
    it { is_expected.to_not be_able_to :setting_style, Setting.new }
    it { is_expected.to_not be_able_to :setting_routes, Setting.new }
    it { is_expected.to_not be_able_to :setting_admin_rules, Setting.new }
    it { is_expected.to_not be_able_to :setting_caching, Setting.new }
    it { is_expected.to_not be_able_to :setting_visibility, Setting.new }
    it { is_expected.to_not be_able_to(:reset_votes, Shop.new) }
  end

  context 'country_manager' do
    let(:user) { create(:country_manager, countries: countries) }

    it { is_expected.to_not be_able_to :manage, AffiliateNetwork.new }
    it { is_expected.to be_able_to :manage, Alert.new }
    it { is_expected.to be_able_to :manage, Banner.new }
    it { is_expected.to be_able_to :manage, Campaign.new }
    it { is_expected.to be_able_to :manage, CampaignImport.new }
    it { is_expected.to be_able_to :manage, Category.new }
    it { is_expected.to be_able_to :manage, Coupon.new }
    it { is_expected.to be_able_to :manage, CouponCode.new }
    it { is_expected.to be_able_to :manage, CouponCodeImport.new }
    it { is_expected.to be_able_to :manage, CouponImport.new }
    it { is_expected.to be_able_to :manage, CsvExport.new }
    it { is_expected.to be_able_to :manage, Medium.new }
    it { is_expected.to be_able_to :manage, Setting.new }
    it { is_expected.to be_able_to :manage, Shop.new }
    it { is_expected.to be_able_to :manage, ShopImport.new }
    it { is_expected.to be_able_to :manage, StaticPage.new }
    it { is_expected.to be_able_to :manage, Translation.new }
    it { is_expected.to be_able_to :manage, Widget.new }
    it { is_expected.to be_able_to :manage, AwinMigration.new }

    it { is_expected.to be_able_to :read, Country.new }
    it { is_expected.to be_able_to :read, Global.new }
    it { is_expected.to be_able_to :read, RedirectRule.new }
    it { is_expected.to be_able_to :read, Site.new }
    it { is_expected.to be_able_to :read, User.new }
    it { is_expected.to be_able_to :read, :quality }
    it { is_expected.to be_able_to :read, AffiliateNetwork.new }

    it { is_expected.to be_able_to :synch_keywords, Shop.new }

    it { is_expected.to_not be_able_to :change_status, User.new }
    it { is_expected.to_not be_able_to :change_status, Category.new }
    it { is_expected.to_not be_able_to :setting_style, Setting.new }
    it { is_expected.to_not be_able_to :setting_routes, Setting.new }
    it { is_expected.to_not be_able_to :setting_admin_rules, Setting.new }
    it { is_expected.to_not be_able_to :setting_caching, Setting.new }
    it { is_expected.to_not be_able_to :setting_visibility, Setting.new }
    it { is_expected.to_not be_able_to :setting_tracking, Setting.new }
    it { is_expected.to_not be_able_to(:reset_votes, Shop.new) }
  end

  context 'country_editor' do
    let(:user) { create(:country_editor, countries: countries) }

    it { is_expected.to be_able_to :manage, Alert.new }
    it { is_expected.to be_able_to :manage, Banner.new }
    it { is_expected.to be_able_to :manage, Campaign.new }
    it { is_expected.to be_able_to :manage, CampaignImport.new }
    it { is_expected.to be_able_to :manage, Coupon.new }
    it { is_expected.to be_able_to :manage, CouponCode.new }
    it { is_expected.to be_able_to :manage, CouponCodeImport.new }
    it { is_expected.to be_able_to :manage, CouponImport.new }
    it { is_expected.to be_able_to :manage, CsvExport.new }
    it { is_expected.to be_able_to :manage, Medium.new }
    it { is_expected.to be_able_to :manage, Shop.new }
    it { is_expected.to be_able_to :manage, ShopImport.new }
    it { is_expected.to be_able_to :manage, Translation.new }
    it { is_expected.to be_able_to :manage, Widget.new }

    it { is_expected.to be_able_to :read, Category.new }
    it { is_expected.to be_able_to :read, Country.new }
    it { is_expected.to be_able_to :read, Global.new }
    it { is_expected.to be_able_to :read, RedirectRule.new }
    it { is_expected.to be_able_to :read, Setting.new }
    it { is_expected.to be_able_to :read, Site.new }
    it { is_expected.to be_able_to :read, StaticPage.new }
    it { is_expected.to be_able_to :read, User.new }
    it { is_expected.to be_able_to :read, :quality }
    it { is_expected.to be_able_to :read, AffiliateNetwork.new }

    it { is_expected.to_not be_able_to :synch_keywords, Shop.new }
    it { is_expected.to_not be_able_to :manage, AwinMigration.new }
    it { is_expected.to_not be_able_to(:reset_votes, Shop.new) }
    it { is_expected.to_not be_able_to :change_status, Category.new }
  end

  context 'freelancer' do
    context 'without further authorization' do
      let(:user) { create(:freelancer_no_access, sites: sites) }

      it { is_expected.to be_able_to :manage, Alert.new }
      it { is_expected.to be_able_to :manage, CsvExport.new }
      it { is_expected.to be_able_to :manage, Medium.new }

      it { is_expected.to be_able_to :read, Global.new }
      it { is_expected.to be_able_to :read, Site.new }
      it { is_expected.to be_able_to :read, user }

      it { is_expected.to_not be_able_to :manage, Banner.new }
      it { is_expected.to_not be_able_to :manage, Coupon.new }
      it { is_expected.to_not be_able_to :manage, Country.new }
      it { is_expected.to_not be_able_to :manage, CouponCode.new }
      it { is_expected.to_not be_able_to :manage, CouponCodeImport.new }
      it { is_expected.to_not be_able_to :manage, CouponImport.new }
      it { is_expected.to_not be_able_to :manage, Shop.new }
      it { is_expected.to_not be_able_to :manage, ShopImport.new }
      it { is_expected.to_not be_able_to :manage, AwinMigration.new }
      it { is_expected.to_not be_able_to :manage_metas, :all }
      it { is_expected.to_not be_able_to :manage, Widget.new }

      it { is_expected.to_not be_able_to :read, AffiliateNetwork.new }

      it { is_expected.to be_able_to :read, :quality }

      it { is_expected.to_not be_able_to :synch_keywords, Shop.new }
      it { is_expected.to_not be_able_to(:reset_votes, Shop.new) }
    end

    context 'without further authorization' do
      context 'cannot shops' do
        let(:user) { create(:freelancer_no_access, can_shops: false, sites: sites) }
        it { is_expected.to_not be_able_to :manage, Shop.new }
        it { is_expected.to_not be_able_to :manage, ShopImport.new }
        it { is_expected.to_not be_able_to(:reset_votes, Shop.new) }
      end

      context 'cannot coupons' do
        let(:user) { create(:freelancer_no_access, can_coupons: false, sites: sites) }
        it { is_expected.to_not be_able_to :manage, Coupon.new }
        it { is_expected.to_not be_able_to :manage, CouponCode.new }
        it { is_expected.to_not be_able_to :manage, CouponCodeImport.new }
        it { is_expected.to_not be_able_to :manage, CouponImport.new }
      end

      context 'cannot metas' do
        let(:user) { create(:freelancer_no_access, can_metas: false, sites: sites) }
        it { is_expected.to_not be_able_to :manage_metas, :all }
      end

      context 'cannot widgets' do
        let(:user) { create(:freelancer_no_access, can_widgets: false, sites: sites) }
        it { is_expected.to_not be_able_to :manage, Widget.new }
      end

      context 'cannot qa' do
        let(:user) { create(:freelancer_no_access, can_qa: false, sites: sites) }
        it { is_expected.to_not be_able_to :manage, :quality }
        it { is_expected.to be_able_to :read, :quality }
      end
    end

    context 'with further authorization' do
      context 'can shops' do
        let(:user) { create(:freelancer_no_access, can_shops: true, sites: sites) }
        it { is_expected.to be_able_to :manage, Shop.new }
        it { is_expected.to be_able_to :manage, ShopImport.new }
        it { is_expected.to_not be_able_to(:reset_votes, Shop.new) }
      end

      context 'can coupons' do
        let(:user) { create(:freelancer_no_access, can_coupons: true, sites: sites) }
        it { is_expected.to be_able_to :manage, Coupon.new }
        it { is_expected.to be_able_to :manage, CouponCode.new }
        it { is_expected.to be_able_to :manage, CouponCodeImport.new }
        it { is_expected.to be_able_to :manage, CouponImport.new }
      end

      context 'can metas' do
        let(:user) { create(:freelancer_no_access, can_metas: true, sites: sites) }
        it { is_expected.to be_able_to :manage_metas, :all }
      end

      context 'can widgets' do
        let(:user) { create(:freelancer_no_access, can_widgets: true, sites: sites) }
        it { is_expected.to be_able_to :manage, Widget.new }
      end

      context 'can qa' do
        let(:user) { create(:freelancer_no_access, can_qa: true, sites: sites) }
        it { is_expected.to be_able_to :manage, :quality }
      end
    end
  end

  context 'partner' do
    let(:user) { create(:partner, sites: sites) }

    it { is_expected.to be_able_to :read, Category.new }
    it { is_expected.to be_able_to :read, Coupon.new }
    it { is_expected.to be_able_to :read, CouponCode.new }
    it { is_expected.to be_able_to :read, Shop.new }
    it { is_expected.to be_able_to :read, Site.new }
    it { is_expected.to be_able_to :read, user }

    it { is_expected.to_not be_able_to :manage, Alert.new }
    it { is_expected.to_not be_able_to :synch_keywords, Shop.new }
    it { is_expected.to_not be_able_to :manage, AwinMigration.new }
    it { is_expected.to_not be_able_to(:reset_votes, Shop.new) }

    it { is_expected.to_not be_able_to :read, AffiliateNetwork.new }
  end
end
