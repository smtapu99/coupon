class Medium < ApplicationRecord
  include ActsAsSiteable

  # Validation
  validates_presence_of :file_name

  # Uploader
  mount_uploader :file_name , Admin::MediaUploader if (ENV['RAKE_IMPORT'].nil?)

  def self.grid_filter(params)
    query = self
    query = query.where(site_id: params[:site_id])
    query = query.where(id: params[:id]) if params[:id].present?
    query = query.where('file_name like ?', "#{params[:file_name]}%") if params[:file_name].present?
    query = query.where('created_at >= ?', "#{params[:created_at_from]}%") if params['created_at_from'].present?
    query = query.where('created_at <= ?', "#{params[:created_at_to]}%") if params['created_at_to'].present?
    query
  end
end
