require 'vue_data/campaign'

module Admin
  class CampaignsController < BaseController
    include ApplicationHelper

    before_action :authenticate_admin_user!
    load_and_authorize_resource

    before_action :set_campaign, only: [:edit, :update, :change_newsletter_box_display_options]
    after_action :purge_proxy_cache, only: [:update]

    # GET /admin/campaigns
    # GET /admin/campaigns.json
    def index
      respond_to do |format|
        format.json { render json: VueData::Campaign.render_json(Site.current.id, params), status: :ok }
        format.html
      end
    end

    # GET /admin/campaigns/new
    def new
      @campaign = Campaign.new
      @campaign.setting = Setting.new
      @campaign.end_date = Time.zone.now + 1.month # presets a end_date in one month
    end

    # GET /admin/campaigns/1/edit
    def edit
    end

    # POST /admin/campaigns
    # POST /admin/campaigns.json
    def create
      @campaign = Campaign.new(campaign_params)
      @campaign.setting = Setting.new(value: campaign_params[:setting_attributes].to_h.to_ostruct_recursive)
      @campaign.setting.site_id = campaign_params[:site_id] if campaign_params[:site_id].present?

      respond_to do |format|
        if @campaign.save
          @campaign.purge_resource_key

          format.html { redirect_to admin_campaigns_url, notice: 'Campaign was successfully created.' }
          format.json { render action: 'show', status: :created, location: @campaign }
        else
          format.html { render action: 'new' }
          format.json { render json: @campaign.errors, status: :unprocessable_entity }
        end
      end
    end

    def export_modal
      @campaign = Campaign.new
      respond_to do |format|
        format.js
      end
    end

    def export
      csv_export = CsvExport.new(export_type: 'Campaign', params: params[:campaign])
      csv_export.user_id = User.current.id

      respond_to do |format|
        if csv_export.save
          Resque.enqueue(CsvExportWorker, csv_export.id)
          format.html { redirect_to admin_csv_exports_path, notice: 'File is beeing processed' }
        else
          csv_export.update_attribute(:status, 'error')
          redirect_to 'index', notice: 'Error while processing the requested file'
        end
      end
    end

    # PATCH/PUT /admin/campaigns/1
    # PATCH/PUT /admin/campaigns/1.json
    def update
      @campaign.slug_mutable = 1 if User.current.is_admin?
      respond_to do |format|
        # Every role besides puplisher needs a site_id for updating
        params[:campaign][:setting_attributes][:site_id] = @setting.site_id if @setting.present?

        if @campaign.update(campaign_params)
          @campaign.purge_resource_key

          format.html { redirect_to admin_campaigns_url, notice: 'Campaign was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @campaign.errors, status: :unprocessable_entity }
        end
      end
    end

    def import_template
      @campaigns = Campaign.where('1=0')
      render 'export', formats: :xlsx, layout: false, filename: "campaigns_import_template_#{Time.zone.now.to_date}"
    end

    private

    def purge_proxy_cache
      return unless @campaign.valid?

      urls = []
      urls << dynamic_url_for('campaigns', 'show', slug: @campaign.slug, host: @campaign.site.hostname, only_path: false)
      urls << dynamic_campaign_url_for(@campaign) if @campaign.is_root_campaign?

      CacheService.new(@campaign.site).purge(urls)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_campaign
      @campaign = Campaign.find_by(id: params[:id], site_id: Site.current.id) || not_found
      @setting  = @campaign.setting
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def campaign_params
      params.require(:campaign).permit(
        :status,
        :name,
        :slug,
        :blog_feed_url,
        :box_color,
        :max_coupons,
        :coupon_filter_text,
        :h1_first_line,
        :priority_coupon_ids,
        :sem_logo_url,
        :sem_background_url,
        :template,
        :h1_second_line,
        :nav_title,
        :parent_id,
        :hide_newsletter_box,
        :start_date,
        :end_date,
        :shop_id,
        :show_footer,
        :is_root_campaign,
        :coupons_on_top,
        related_shop_ids:[],
        html_document_attributes:[
          :meta_robots,
          :meta_keywords,
          :meta_description,
          :meta_title,
          :content,
          :welcome_text,
          :h1,
          :h2,
          :htmlable_id,
          :htmlable_type,
          :head_scripts,
          :header_image,
          :header_image_dark_filter,
          :mobile_header_image,
          :header_font_color,
          :header_cta_text,
          :header_cta_anchor_link,
          :header_size,
          :header_text_background,
          :header_text_v_alignment,
          :header_text_h_alignment,
          :countdown_date,
          :remove_header_image
        ],
        setting_attributes:[
          :site_id,
           publisher_site:[
            :custom_head_scripts,
            :show_navigation_link,
            :show_footer
           ],
           widget_ranking:[
            :show_featured_images_before_coupons
           ]
        ]
      )
    end
  end
end
