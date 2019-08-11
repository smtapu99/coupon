module ActsAsRoutesReloader
  extend ActiveSupport::Concern

  included do
    attr_accessor :avoid_reload_routes

    before_save :check_attribute_changed
    after_save :update_routes_timestamp, if: :routes_reloading_required?
    after_save :reload_routes, unless: -> { avoid_reload_routes }

    private

    def check_attribute_changed
      @attribute_changed = (self.is_a?(Site) && hostname_changed?) || (self.is_a?(Campaign) && is_root_campaign_changed?) || (self.is_a?(Setting) && routes_changed)
    end

    def routes_reloading_required?
      @attribute_changed
    end

    def update_routes_timestamp
      reloading_site = self.is_a?(Site) ? self : site
      RoutesChangedTimestamp.update_timestamp(reloading_site)
    end

    def reload_routes
      DynamicRoutes.reload
    end
  end
end
