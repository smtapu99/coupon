class Freelancer < User
  has_many :coupons, -> { distinct }, through: :sites
  has_many :shops, -> { distinct }, through: :sites
  has_many :sites, -> { distinct }, through: :site_users, validate: false
  has_many :alerts, -> { distinct }, through: :sites
  has_many :countries, -> { distinct }, through: :sites, validate: false
  has_many :static_pages, -> { distinct }, through: :sites
  has_many :campaigns, -> { distinct }, through: :sites
  has_many :categories, -> { distinct }, through: :sites

  after_initialize :init_role

  default_scope { where(role: 'freelancer') }

  def init_role
    self.role = 'freelancer' if new_record?
  end

  def password_required?
    false
  end
end
