class CsvExport < ApplicationRecord

  belongs_to :user

  serialize :params
  serialize :error_messages

  mount_uploader :file, Admin::JobFileUploader

  # used for migration with zero downtime. disables writes to the rejected colums
  def self.columns
    super.reject { |column| ['site_id'].include?(column.name) }
  end

  def self.grid_filter(params)
    query = self
    query = query.where('1=1')
    query = query.where(user: User.current.allowed_active_users_of(self, true)) if User.current.present?
    query = query.where(id: params[:id]) if params[:id].present?
    query = query.where(export_type: params[:export_type]) if params[:export_type].present?
    query = query.where(status: params[:status]) if params[:status].present?
    query = query.where(user: params[:user]) if params[:user].present?
    query = query.where('created_at >= ?', params['created_at_from']) if params['created_at_from'].present?
    query = query.where('created_at <= ?', params['created_at_to']) if params['created_at_to'].present?
    query = query.where('last_executed >= ?', params['last_executed_from']) if params['last_executed_from'].present?
    query = query.where('last_executed <= ?', params['last_executed_to']) if params['last_executed_to'].present?
    query
  end

  def self.grid_filter_dropdowns
    h = {}
    h[:user] = User.current.allowed_active_users_of(self, true).map do |user|
      { user.id => user.full_name }
    end
    h[:user].insert(0, {'' => 'all'})
    h
  end

  def exportable
    self.export_type.classify.constantize
  end

  def open?
    self.status == 'pending' || self.status == 'running'
  end

  def run_export
    exportable.export(self.params)
  end

  def site
    raise "Invalid call of 'site' in coupon_imports.rb; Site is not a relation of csv_export anymore; Please inform admin."
  end

  def site_id
    raise "Invalid call of 'site_id' in coupon_imports.rb; Site is not a relation of csv_export anymore; Please inform admin."
  end

  def sanitized_params_string
    return '' unless params.present?
    string = ''
    params.each do |k, v|
      if v.present? && [*v].reject(&:blank?).present?
        if ['shop_id', 'shop_ids'].include?(k)
          string += '<b>Shops</b>: ' + Shop.where(id: v).pluck(:slug).join(', ') + '<br />'
        else
          string += "<b>#{k.to_s.titleize}</b>: #{[*v].reject(&:blank?).join(', ')}<br />"
        end
      end
    end
    string
  end
end

