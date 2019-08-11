module ActsAsWidgetSpace
  extend ActiveSupport::Concern

  included do

    serialized_attr_accessor :widget_order

    def self.by_name name
      where(name: name)
    end

    def self.by_site site_id
      where(site_id: site_id)
    end

    def self.by_campaign campaign_id
      where(campaign_id: campaign_id)
    end

    # returns all widgets of the given area, in the given widget_order
    # in case the widget doesnt exist anymore it deletes it from the area
    #
    # @return [Array] Widgets
    def widgets
      widgets = []

      return widgets if widget_order.blank?

      widget_order.each do |id|
        widget = Widget.find_by(id: id, site_id: site_id, campaign_id: campaign_id)
        if widget.present?
          widgets << widget
        else
          delete_widget id
        end
      end

      widgets
    end

    # deletes a widget from the widget_area
    # @param  widget_id [Integer] widget_id
    #
    # @return [Boolean] true || false
    def delete_widget widget_id
      widget_order.delete(widget_id)
      _value = self.value
      _value.widget_order = widget_order
      self.update_column(:value, _value)
    end

  end
end
