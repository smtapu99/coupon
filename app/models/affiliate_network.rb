class AffiliateNetwork < ApplicationRecord
  include ActsAsStatusable
  has_statuses(
    active: 'active',
    blocked: 'blocked'
  )

  # Relations
  has_many :coupons

  # Validation
  validates_presence_of :name
  validates_uniqueness_of :name

  scope :active, -> { where(status: statuses[:active]) }

  def self.grid_filter(params)
    query = self
    query = query.where('1=1')
    query = query.where(id: params[:id]) if params[:id].present?
    query = query.where('name like ?', "%#{params[:name]}%") if params[:name].present?
    query = query.where('affiliate_networks.slug like ?', "%#{params[:slug]}%") if params[:slug].present?
    query = query.where(status: statuses[params[:status].to_sym]) if params[:status].present?
    query
  end
end
