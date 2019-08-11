class SuperUser < User
  has_many :coupons, -> { distinct }, through: :sites
  has_many :shops, -> { distinct }, through: :sites
  has_many :countries, -> { distinct }, through: :user_countries, validate: false
  has_many :sites, -> { distinct }, through: :countries, validate: false
  has_many :alerts, -> { distinct }, through: :sites
  has_many :static_pages, -> { distinct }, through: :sites
  has_many :campaigns, -> { distinct }, through: :sites
  has_many :categories, -> { distinct }, through: :sites

  after_initialize :init_role

  default_scope { where(role: 'admin') }

  def init_role
    self.role = 'admin' if new_record?
  end

  # a super user always sees all
  def alerts
    Alert.all
  end

  # a super user always sees all
  def categories
    Category.all
  end

  def coupons
    Coupon.all
  end

  def shops
    Shop.all
  end

  def countries
    Country.all
  end

  def country_ids
    countries.map(&:id)
  end

  def sites
    Site.all
  end

  def static_pages
    StaticPage.all
  end

  def campaigns
    Campaign.all
  end

  def categories
    Category.all
  end
end
