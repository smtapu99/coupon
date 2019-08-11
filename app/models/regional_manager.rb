class RegionalManager < User
  has_many :coupons, -> { distinct }, through: :sites
  has_many :shops, -> { distinct }, through: :sites
  has_many :countries, -> { distinct }, through: :user_countries, validate: false
  has_many :sites, -> { distinct }, through: :countries, validate: false
  has_many :alerts, -> { distinct }, through: :sites
  has_many :static_pages, -> { distinct }, through: :sites
  has_many :campaigns, -> { distinct }, through: :sites
  has_many :categories, -> { distinct }, through: :sites

  after_initialize :init_role

  default_scope { where(role: 'regional_manager') }

  def init_role
    self.role = 'regional_manager' if new_record?
  end

end
