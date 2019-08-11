module Admin
  module OptionHelper

    def color_select options, selected = nil, include_blank=false

      @bg_color_settings = bg_color_settings(options, selected, include_blank)

    end

    def bg_color_settings options, selected, include_blank=false

      defaults = {
        color_cloud:  "#ecf0f1",
        color_freedom:  "#2ecc71",
        color_gold:  "#f1c50e",
        color_juicy:  "#ff7828",
        color_mamba:  "#5d6279",
        color_ready:  "#e64c3c",
        color_royal:  "#9c59b7",
        color_sky:  "#3399cc",
        color_main:  "#e64c3c"
      }

      settings = Setting::get('style')

      @bg_settings ||= if settings.present?
        defaults.merge(settings.marshal_dump) do |key, old, neww|
          neww == '' ? old : neww
        end
      else
        defaults
      end

      values = ''

      if include_blank == true
        values += '<option '+ (selected.present? && selected == '' ? 'selected' : '') +' value="">'+'Please select...'+'</option>'
      end

      options.each do |o|

        values += '<option '+ (selected.present? && selected == o[1] ? 'selected' : '') +' value="'+o[1]+'" data-hex="'+@bg_settings["color_#{o[1]}".to_sym]+'">'+o[0]+'</option>'

      end

      values
    end
  end
end

