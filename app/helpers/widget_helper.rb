module WidgetHelper
  def render_widget(widget, options)
    begin
      service_class = "Widgets::#{widget.name.camelcase}Service".constantize
    rescue
      service_class = Widgets::BaseService
    end
    service_object = service_class.new(widget)
    widget_params = service_object.get_params(options)

    if widget_params[:locals].present?
      if widget_params[:locals][:coupons].present?
        surrogate_key_header 'coupons', widget_params[:locals][:coupons].map(&:resource_key)
      end

      if widget_params[:locals][:shops].present?
        surrogate_key_header 'shops', widget_params[:locals][:shops].map(&:resource_key)
      end
      widget_params[:locals][:order_number] = options[:order_number]
    end

    begin
      render template: widget_params[:file], locals: widget_params[:locals]
    rescue ActionView::MissingTemplate => e
      ApplicationMailer.inform_developer("The widget '#{widget.name}' on site '#{@site.site.name} ' should be rendered but the partial is missing", { widget: widget }).deliver_now
      return
    end
  end

  def to_bootstrap_classes(columns)
    case columns.to_i
    when 3
      ''
    when 2
      'col-sm-8'
    else
      'col-sm-4'
    end
  end

  def hot_offer_size size
    case size
    when 'small'
      'col-md-4'
    when 'large'
      'col-md-8'
    else
      'col-md-6'
    end
  end

  def hot_offer_modifiers offer
    modifiers = []

    if offer[:size] == 'small'
      modifiers << 'offer--small'
    else
      if offer[:text_alignment] == 'left'
        modifiers << 'offer--left-align'
      elsif offer[:text_alignment] == 'right'
        modifiers << 'offer--right-align'
      end
    end

    if offer[:label_color] == 'yellow'
      modifiers << 'offer--yellow-label'
    elsif offer[:label_color] == 'green'
      modifiers << 'offer--green-label'
    end

    if offer[:box_type] == 'white'
      modifiers << 'offer--no-bg'
    elsif offer[:box_type] == 'gray'
      modifiers << 'offer--bg'
    elsif offer[:box_type] == 'background'
      modifiers << 'offer--full-bg'
    end

    return modifiers.join(' ')
  end

  def premium_offers_size type
    case type
    when '25', '25-full-bg', '25-colored'
      'col-md-3 col-sm-4'
    when '25-2019'
      'col-md-6 col-lg-3'
    when '33-colored-full-bg'
      'col-lg-4 col-md-12 col-sm-12'
    when '50', '50-small'
      'col-md-6'
    when '75', '75-head-picture'
      'col-md-9 col-sm-8'
    else
      'col-md-12'
    end
  end

  def premium_offers_size_v4 type
    case type
    when '25', '25-full-bg', '25-colored'
      'col-lg-3 col-md-4'
    when '25-2019'
      'col-md-6 col-lg-3'
    when '33-colored-full-bg'
      'col-xl-4'
    when '50', '50-small'
      'col-lg-6'
    when '75', '75-head-picture'
      'col-lg-9 col-md-8'
    else
      'col-12'
    end
  end

  def premium_offers_modifiers widget
    modifiers = []

    modifiers << "premium-offer--bg-#{widget['background_position']}" if widget['background_position'].present?

    case widget['background_color']
    when 'white'
      modifiers << 'premium-offer--white-bg'
    when 'orange'
      modifiers << 'premium-offer--orange-bg'
    when 'green'
      modifiers << 'premium-offer--green-bg'
    when 'blue'
      modifiers << 'premium-offer--blue-bg'
    when 'telegraph'
      modifiers << 'premium-offer--telegraph-bg'
    when 'independent'
      modifiers << 'premium-offer--independent-bg'
    when 'social'
      modifiers << 'premium-offer--social-blue-bg'
    when 'gold'
      modifiers << 'premium-offer--gold-bg'
    when 'yellow'
      modifiers << 'premium-offer--yellow-paste-bg'
    when 'pastel-purple'
      modifiers << 'premium-offer--pastel-purple-bg'
    when 'bubblegum'
      modifiers << 'premium-offer--bubblegum-bg'
    when 'grey'
      modifiers << 'premium-offer--grey-bg'

    else
      ''
    end

    case widget['background_opacity']
    when 'white'
      modifiers << 'premium-offer--opacity-white'
    when 'black'
      modifiers << 'premium-offer--opacity-black'
    else
      ''
    end

    modifiers.join(' ')
  end
end
