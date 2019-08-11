class User < ApplicationRecord
  include ActsAsCurrentEntity
  has_one_time_password

  attr_accessor :assigned_shops_count, :token_otp

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :trackable, :validatable
  devise :database_authenticatable, :trackable, :validatable, :timeoutable, :lockable

  enum otp_module: { disabled: 0, enabled: 1 }, _prefix: true
  # validates_inclusion_of :role, in: :available_roles

  has_many :assigned_shops, class_name: 'Shop', foreign_key: 'person_in_charge_id'
  has_many :user_countries
  has_many :countries, through: :user_countries
  has_many :site_users

  before_save :set_hidden_fields

  after_commit :clear_user_countries_and_sites_cache

  validate :site_present
  validate :country_present

  ADMIN_ROLES = [:admin].freeze
  SITE_BASED_ROLES = [:freelancer, :partner].freeze
  COUNTRY_BASED_ROLES = [:regional_manager, :country_manager, :country_editor].freeze
  ALL_ROLES = (ADMIN_ROLES + COUNTRY_BASED_ROLES + SITE_BASED_ROLES).freeze

  ALLOWED_USER_ROLES = {
    admin: ALL_ROLES,
    regional_manager: ALL_ROLES.except(:admin, :regional_manager),
    country_manager: [
      :country_editor,
      :freelancer
    ],
    country_editor: [:freelancer],
    freelancer: [],
    partner: []
  }.freeze

  scope :active, -> { where(status: 'active') }

  def set_hidden_fields
    return unless new_record?

    self.sign_in_count      = 0
    self.current_sign_in_at = Time.zone.now
    self.last_sign_in_at    = Time.zone.now
  end

  def self.subclasses
    ALL_ROLES.except(:admin).map(&:to_s).map(&:classify) << 'SuperUser'
  end

  def self.grid_filter(params)
    query = self
    query = query.where(id: User.current.allowed_user_ids)
    query = query.where(status: params[:status]) if params[:status].present?
    query = query.where(id: params[:id]) if params[:id].present?
    query = query.where('first_name like ?', "%#{params[:first_name]}%") if params[:first_name].present?
    query = query.where('last_name like ?', "%#{params[:last_name]}%") if params[:last_name].present?
    query = query.where('email like ?', "%#{params[:email]}%") if params[:email].present?
    query = query.where('role like ?', "%#{params[:role]}%") if params[:role].present?
    query
  end

  def self.full_name(user)
    "#{user.first_name} #{user.last_name}"
  end

  def available_roles_for_dropdown
    allowed_user_roles.map do |role|
      [role.to_s.humanize.titleize, role.to_s]
    end
  end

  def hsc_cache_key
    ['user', id, 'hsc']
  end

  def reset_hsc_cache
    Rails.cache.delete(hsc_cache_key)
  end

  def has_sites_or_countries?
    @has_sites_or_countries ||= if Rails.env.test?
      uncached_has_sites_or_countries?
    else
      Rails.cache.fetch(hsc_cache_key) do
        uncached_has_sites_or_countries?
      end
    end
  end

  def uncached_has_sites_or_countries?
    case role.to_sym
    when :admin
      true
    when *COUNTRY_BASED_ROLES
      (user_countries.count >= 1) ? true : false
    when *SITE_BASED_ROLES
      (site_users.count >= 1) ? true : false
    else
      false
    end
  end

  # A user can have either sites or countries assigned
  def country_required?
    COUNTRY_BASED_ROLES.include?(role.to_sym)
  end

  # A user can have either sites or countries assigned
  def site_required?
    SITE_BASED_ROLES.include?(role.to_sym)
  end

  def reset_role_relations!(new_role)
    raise ArgumentError, 'Invalid Role' unless ALL_ROLES.include?(new_role.to_sym)
    update_attribute(:role, new_role)
    SiteUser.where(user_id: id).destroy_all
    UserCountry.where(user_id: id).destroy_all
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  # non admin users can only sign in when they have sites or countries assigned
  # in any case a user needs to be active
  def allowed_to_sign_in?
    active? && \
      (is_admin? || \
      country_required? && user_countries.present? || \
      site_required? && site_users.present?)
  end

  def allowed_to_change_role_of(user)
    is_admin? || non_admin_and_allowed_to_update_user?(user)
  end

  def active?
    status == 'active'
  end

  def is_super_admin?
    id == 1
  end

  def is_admin?
    role == 'admin'
  end

  def is_partner?
    role == 'partner'
  end

  def is_country_manager?
    role == 'country_manager'
  end

  def is_country_editor?
    role == 'country_editor'
  end

  def is_regional_manager?
    role == 'regional_manager'
  end

  def is_freelancer?
    role == 'freelancer'
  end

  def can_metas?
    return true unless is_freelancer?
    can_metas
  end

  def can_shops?
    return true unless is_freelancer?
    can_shops
  end

  def can_coupons?
    return true unless is_freelancer?
    can_coupons
  end

  def allowed_to_manage(type)
    type = 'admin' if type == 'super_user'
    allowed_user_roles.include?(type.to_sym)
  end

  def allowed_user_roles(same_role_allowed = false)
    roles = [*ALLOWED_USER_ROLES[role.to_sym]]

    if same_role_allowed
      roles << self.role.to_sym
    end

    roles.uniq
  end

  def allowed_active_users_of(klass, same_role_allowed = false)
    raise 'Invalid model passed; klass needs to respond to user_id' unless klass.column_names.include?('user_id')
    ids = klass.where(user_id: allowed_user_ids(same_role_allowed)).pluck(:user_id).uniq
    User.active.where(id: ids).order(:first_name)
  end

  # Users are allowed to see just other users from the same allowed sites or countries
  # but just those who have the same or a lower role level.
  #
  # @return [Array] User ids
  def allowed_user_ids(same_role_allowed = false)
    return User.all.pluck(:id) if role == 'admin'

    ids = []
    ids << id

    if allowed_user_roles(same_role_allowed).present?
      ids += SiteUser.where(user_id: user_ids_with_allowed_roles(same_role_allowed), site_id: site_ids).pluck(:user_id)
      if country_required?
        ids += UserCountry.where(user_id: user_ids_with_allowed_roles(same_role_allowed), country_id: country_ids).pluck(:user_id)
      end
    end

    ids.uniq
  end

  # def sites
  #   return site_users.map(&:site) if site_required?
  #   countries.map(&:sites).flatten
  # end
  def allowed_locales
    User.current.countries.map(&:locale)
  end

  def allowed_site_ids
    @allowed_site_ids ||= sites.pluck(:id)
  end

  def to_subclass
    klass = role.classify.constantize
    if klass == Admin
      klass = SuperUser
    end
    klass
  end

  def class_by_role
    return SuperUser if role == 'admin'
    return User if role.nil?

    role.classify.constantize
  end

  def self.cached_current_user_countries
    Rails.cache.fetch([current.id, name, 'current_user_countries']) do
      current.countries.map(&:id)
    end
  end

  def self.cached_current_user_sites
    Rails.cache.fetch([current.id, name, 'current_user_sites']) do
      current.sites.map(&:id)
    end
  end

  private

  def user_ids_with_allowed_roles(same_role_allowed)
    User.where(role: allowed_user_roles(same_role_allowed)).pluck(:id)
  end

  def non_admin_and_allowed_to_update_user?(user)
    user.id != id && \
      (!is_admin? && allowed_to_manage(user.role) && !user.new_record?)
  end

  def site_present
    errors.add(:sites, 'Please select at least one site') if site_required? && sites.blank?
  end

  def country_present
    errors.add(:countries, 'Please select at least one country') if country_required? && countries.blank?
  end

  def clear_user_countries_and_sites_cache
    Rails.cache.delete([id, self.class.superclass.name, 'current_user_countries'])
    Rails.cache.delete([id, self.class.superclass.name, 'current_user_sites'])
  end

  # returns the country ids of the current model
  #
  # @return [array] array of countries
  def current_user_countries
    countries.map(&:id)
  end

  def current_user_sites
    sites.map(&:id)
  end
end
