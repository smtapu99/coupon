class StaticPage < ApplicationRecord
  include ActsAsSluggable
  include ActsAsSiteable

  delegate :meta_robots, :meta_keywords, :meta_description, :meta_title, to: :html_document, prefix: true

  has_one :html_document, as: :htmlable, dependent: :destroy

  accepts_nested_attributes_for :html_document, update_only: true

  validates_presence_of :title

  def self.cleanup
    where('slug != ?', '/') # prvent from showing static pages which are just content holders
  end

  def self.active
    joins(:html_document)
     .where(status: 'active')
     .where('html_documents.meta_robots not like ?', '%noindex%')
  end

  def self.grid_filter(params)
    query = self
    query = query.where(site_id: params[:site_id])
    query = query.where(id: params[:id]) if params[:id].present?
    query = query.where(status: params[:status]) if params[:status].present?
    query = query.joins(:site).where('sites.hostname like ?', "%#{params[:site]}%" ) if params[:site].present?
    query = query.where('title like ?', "#{params[:title]}%") if params[:title].present?
    query = query.where('slug like ?', "#{params[:slug]}%") if params[:slug].present?
    query
  end

end
