class AdminAbility
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in (current) user. For example:
    #
    #   if user
    #     can :access, :all
    #   else
    #     can :access, :home
    #     can :create, [:users, :sessions]
    #   end
    #
    # Here if there is a user he will be able to perform any action on any controller.
    # If someone is not logged in he can only access the home, users, and sessions controllers.
    #
    # The first argument to `can` is the action the user can perform. The second argument
    # is the controller name they can perform that action on. You can pass :access and :all
    # to represent any action and controller respectively. Passing an array to either of
    # these will grant permission on each item in the array.
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities

    user = user.present? ? user.to_subclass.find(user.id) : User.new

    has_sites_or_countries ||= user.has_sites_or_countries?
    guest_rules and return unless has_sites_or_countries

    @forbidden_site_ids = Site.where.not(id: user.allowed_site_ids).pluck(:id)

    alias_action :index, :show, :edit, :coupon_codes, to: :read
    alias_action :index, :edit, :update, to: :manage_expired_exclusive

    case user.role
    when 'admin'
      if user.is_super_admin?
        super_admin_rules
      else
        admin_rules
      end
    when 'country_manager'
      country_manager_rules(user)
    when 'country_editor'
      country_editor_rules(user)
    when 'regional_manager'
      regional_manager_rules(user)
    when 'freelancer'
      freelancer_rules(user)
    when 'partner'
      partner_rules(user)
    else
      guest_rules
    end
  end

  private

  def restrict_site_access
    can [:set_current_site_id, :unset_current_site_id], User

    return unless @forbidden_site_ids.present?

    cannot :manage, [
      Banner,
      Campaign,
      Category,
      CouponCode,
      Coupon,
      Medium,
      Option,
      ShopKeyword,
      Shop,
      StaticPage,
      Widget], site_id: @forbidden_site_ids
  end

  def super_admin_rules
    can :manage, :all
  end

  def admin_rules
    super_admin_rules
    cannot :reset_votes, Shop
  end

  def regional_manager_rules(user)
    can :manage, [
      AwinMigration,
      Alert,
      Banner,
      Campaign,
      CampaignImport,
      Category,
      Coupon,
      CouponCode,
      CouponCodeImport,
      CouponImport,
      CsvExport,
      Medium,
      Setting,
      Shop,
      ShopImport,
      StaticPage,
      Tag,
      TagImport,
      Translation,
      User,
      Widget
    ]

    can :read, [
      Country,
      Global,
      RedirectRule,
      Site,
      AffiliateNetwork
    ]

    can :change_status, User
    can :synch_keywords, Shop
    can :read, :quality

    can :manage, User, id: user.id # himself

    cannot :setting_style, Setting
    cannot :setting_routes, Setting
    cannot :setting_admin_rules, Setting
    cannot :setting_caching, Setting
    cannot :setting_visibility, Setting
    cannot :reset_votes, Shop
    cannot :change_status, Category

    restrict_site_access
  end

  def country_manager_rules(user)
    regional_manager_rules(user)

    cannot :change_status, User
    cannot :setting_tracking, Setting

    restrict_site_access
  end

  def country_editor_rules(user)
    can :manage, [
      Banner,
      Alert,
      Campaign,
      CampaignImport,
      Coupon,
      CouponCode,
      CouponCodeImport,
      CouponImport,
      CsvExport,
      Medium,
      Shop,
      ShopImport,
      Translation,
      Widget
    ]

    can :read, [
      Category,
      Country,
      Global,
      RedirectRule,
      Setting,
      Site,
      StaticPage,
      User,
      AffiliateNetwork
    ]

    can :manage, User, id: user.id # himself
    can :read, :quality

    cannot :synch_keywords, Shop

    cannot :setting_style, Setting
    cannot :setting_routes, Setting
    cannot :setting_admin_rules, Setting
    cannot :setting_caching, Setting
    cannot :setting_visibility, Setting
    cannot :setting_tracking, Setting
    cannot :reset_votes, Shop
    cannot :change_status, Category

    restrict_site_access
  end

  def freelancer_rules(user)
    can :manage, [
      Alert,
      CsvExport,
      Medium
    ]

    if user.can_coupons?
      can :manage, [
        Coupon,
        CouponCode,
        CouponCodeImport,
        CouponImport
      ]
    end

    if user.can_shops?
      can :manage, [
        Shop,
        ShopImport
      ]
      cannot :reset_votes, Shop
    end

    if user.can_widgets?
      can :manage, Widget
    end

    if user.can_qa?
      can :manage, :quality
    else
      can :read, :quality
    end

    can :read, [
      Country,
      Global,
      Site
    ]

    if user.can_metas?
      can :manage_metas, :all
    end

    can :manage, User, id: user.id # himself


    cannot :manage, Country
    cannot :synch_keywords, Shop

    restrict_site_access
  end

  def partner_rules(user)
    can :read, [
      Category,
      Coupon,
      CouponCode,
      Shop,
      Site
    ]

    can :manage, User, id: user.id # himself

    restrict_site_access
  end

  def guest_rules
    cannot :manage, :all

    restrict_site_access
  end
end
