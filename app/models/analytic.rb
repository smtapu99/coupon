class Analytic
  # # switch to ActiveModel::Model in Rails 4
  # extend ActiveModel::Model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  def self.get_analytics_time_range(params)
    case params[:preset_date]
    when 'last_month'
      1.month.ago.at_beginning_of_month..1.month.ago.at_end_of_month
    when 'last_week'
      1.week.ago.beginning_of_week(:sunday)..1.week.ago.end_of_week(:sunday)
    when 'today'
      Time.zone.now.all_day
    else
      # if no preset_date is set use start_date and/or enddate --- if non is set show 1 month until now
      begin
        start_date = Time.parse(params[:start_date])
        end_date   = Time.parse(params[:end_date])
      rescue
        start_date = Date.today.beginning_of_month
        end_date   = Time.zone.now
      end

      start_date..end_date
    end
  end
end
