class Partner < User
  has_many :coupons, -> { distinct }, through: :sites
  has_many :shops, -> { distinct }, through: :sites
  has_many :sites, -> { distinct }, through: :site_users, validate: false
  has_many :alerts, -> { distinct }, through: :sites
  has_many :countries, -> { distinct }, through: :sites, validate: false
  has_many :campaigns, -> { distinct }, through: :sites
  has_many :categories, -> { distinct }, through: :sites

  after_initialize :init_role

  default_scope { where(role: 'partner') }

  def init_role
    self.role = 'partner' if new_record?
  end

end
