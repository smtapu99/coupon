class Widgets::BaseService

  def initialize widget
    @widget = widget
    raise 'Invalid widget' unless @widget.is_a? WidgetBase
  end

  def get_params options
    load_data options
    return render_params
  end

  private
  # placeholder for special widget-services (see example featured_coupons_service.rb)
  def load_widget_data
  end

  # dynamically attach all instance vars of the load_data methods to the view
  # e.g. { widget: @widget, site: @site, values: widget_values, space: @space, coupons: @coupons }
  def render_params
    vars = {
      file: "widgets/#{@widget.name}",
      locals: {
        values: widget_values
      }
    }

    instance_variables.each do |var|
      vars[:locals][var.to_s.gsub('@', '').to_sym] = eval(var.to_s)
    end

    vars
  end

  def load_data options
    @site = options[:site]
    raise 'Invalid Site Facade' unless @site.is_a? SiteFacade

    #ad_space
    @space = options[:space_name]

    # expiring_coupons needs to be called with AJAX .. if not @ajax_call is true then just an container will be rendered where the content will be hooked into afterwards
    @ajax_call = options[:ajax_call] || false

    load_widget_data
  end

  def widget_values
    @widget.defaults.merge( @widget.value.marshal_dump.select {|k, v| v.present?} )
  end
end
