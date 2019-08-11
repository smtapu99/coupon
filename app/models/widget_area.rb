class WidgetArea < WidgetBase
  include ActsAsWidgetSpace

  before_save :set_area_defaults

  default_scope { where(widget_type: 'widget_area') }

  # Scopes
  def self.main(campaign_id = nil)
    by_area('main', campaign_id)
  end

  def self.footer(campaign_id = nil)
    by_area('footer', campaign_id)
  end

  def self.sidebar(campaign_id = nil)
    by_area('sidebar', campaign_id)
  end

  def self.by_area(area, campaign_id = nil)
    where(site_id: Site.current.id, campaign_id: campaign_id, name: area).first
  end

  private

  def set_area_defaults
    self.widget_type = 'widget_area'
    self.campaign_id = nil if 0 === self.campaign_id.to_i
  end
end
