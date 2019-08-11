class Country < ApplicationRecord
  has_many :coupons
  has_many :categories
  has_many :shops
  has_many :tags

  has_many :sites
  has_many :site_users, through: :sites, source: :users

  has_many :user_countries
  has_many :country_users, through: :user_countries, foreign_key: :country_id, source: :user

  validates_presence_of :name, :locale
  validates_uniqueness_of :name

  after_save :assign_to_super_user

  def self.grid_filter(params)
    query = self
    query = query.where('1=1')
    query = query.where(id: params[:id]) if params[:id].present?
    query = query.where('name like ?', "%#{params[:name]}%") if params[:name].present?
    query = query.where('locale like ?', "%#{params[:locale]}%") if params[:locale].present?
    query
  end

  def self.cultures
    %w[
      af ar at az bg bn bs ca cs cy da de de_AT de_CH el en en_AU en_CA en_GB en_IE en_IN en_NZ en_US eo es es_ES es_419
      es_AR es_CL es_CO es_CR es_MX es_PA es_PE es_VE et eu fa fi fr fr_CA fr_CH gl he hi hi_IN hr hu id is it it_CH ja
      kn ko lo lt lv mk mn ms nb ne nl nn or pl pt pt_BR rm ro ru sk sl sr sv sw th tl tr uk ur uz vi wo zh_CN zh_HK zh_TW
    ]
  end

  def users
    (site_users + country_users).uniq
  end

  def user_ids
    users.map(&:id).uniq
  end

  private
    def assign_to_super_user
      SuperUser.all.each do |su|
        UserCountry.find_or_create_by(country_id: self.id, user_id: su.id)
      end
    end
end
