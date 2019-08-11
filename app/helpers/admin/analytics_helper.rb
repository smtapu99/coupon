module Admin
  module AnalyticsHelper
    def get_analytics_date_group_by_url type
      admin_analytics_path(params.except(:group_by).merge(group_by: type))
    end

    def get_analytics_date_preset_url type
      par = params.except(:start_date, :end_date, :preset_date)
      par = par.except(:group_by) if type == 'today'                      # disables the daily group if just one day selected
      par = par.merge(preset_date: type) if params[:preset_date] != type  # allows to reset selection
      admin_analytics_path(par)
    end

    def get_analytics_button_active_class type
      if %w(last_month last_week today).include? type
        'active' if params[:preset_date] == type
      elsif %w(month week day).include? type
        if params[:group_by] == type or (params[:group_by].blank? and type == 'day' and params[:preset_date] != 'today')
          'active'
        end
      end
    end

    def get_analytics_time_range params
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
          end_date = Time.parse(params[:end_date])
        rescue
          start_date = 1.month.ago
          end_date = Time.zone.now
        end

        start_date..end_date
      end
    end
  end
end
