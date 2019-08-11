require 'vue_data/quality/active_coupons'
require 'vue_data/quality/http_links'
require 'vue_data/quality/invalid_urls'

module Admin
  class QualityController < BaseController
    before_action :init_site_facade, only: [:active_coupons]
    before_action :authorize_quality_access

    def active_coupons
      @title = 'Active Coupons per Shop'
      @info = 'Overview of how many active coupons the shop has today / in 3 days / in 7 days.'

      empty_tier_1 = @site.shops.by_tier_group(1).where(active_coupons_count: 0).count
      empty_tier_2 = @site.shops.by_tier_group(2).where(active_coupons_count: 0).count

      @quicklinks = {
        "<b>#{empty_tier_1}</b> empty tier 1 shops" => '/pcadmin/quality/active_coupons?f%5Bstatus%5D=active&f%5Btier_group%5D=1&f%5Btoday%5D=0',
        "<b>#{empty_tier_2}</b> empty tier 2 shops" => '/pcadmin/quality/active_coupons?f%5Bstatus%5D=active&f%5Btier_group%5D=2&f%5Btoday%5D=0'
      }

      respond_to do |format|
        format.html { render :index }
        format.json { render json: ::VueData::Quality::ActiveCoupons.render_json(Site.current.id, params), status: :ok }
      end
    end

    def http_links
      @title = 'HTTP onpage links on HTTPS sites'
      @info = 'Overview of HTTP onpage links.'

      respond_to do |format|
        format.html { render :index }
        format.json { render json: ::VueData::Quality::HttpLinks.render_json(Site.current.id, params), status: :ok }
      end
    end

    def invalid_urls
      @title = 'Wrong Affiliate Networks'
      @info = 'Overview of coupons where the URL doesnt match with the Validation Regex of the Affiliate Network.'

      respond_to do |format|
        format.html { render :index }
        format.json { render json: ::VueData::Quality::InvalidUrls.render_json(Site.current.id, params), status: :ok }
      end
    end

    private

    def authorize_quality_access
      authorize! :read, :quality
    end

    def init_site_facade
      @site = SiteFacade.new(Site.current)
    end
  end
end
