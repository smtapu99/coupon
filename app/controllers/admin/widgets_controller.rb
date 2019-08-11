module Admin
  class WidgetsController < BaseController
    include ActsAsWidgetController
    include ApplicationHelper

    before_action :authenticate_admin_user!
    load_and_authorize_resource

    before_action :set_widget, only: [:show, :edit, :update, :destroy]
    before_action :set_upload_variables, only: [:create, :update]

    after_action :purge_proxy_cache, only: [:create, :update, :update_widget_area]

    # GET /admin/widgets
    # GET /admin/widgets.json
    def index
      @main    = WidgetArea.main(@campaign_id).present? ? WidgetArea.main(@campaign_id).widgets : []
      @footer  = WidgetArea.footer(@campaign_id).present? ? WidgetArea.footer(@campaign_id).widgets : []
      @sidebar = WidgetArea.sidebar(@campaign_id).present? ? WidgetArea.sidebar(@campaign_id).widgets : []
    end

    def update_widget_area
      campaign_id = nil

      if params.key?(:campaign) && params[:campaign].to_i != 0
        campaign_id = params[:campaign]
      end

      @area = WidgetArea.find_or_initialize_by(site_id: Site.current.id, campaign_id: campaign_id, name: params[:name])

      @area.widget_order = params[:widget_order].nil? ? [] : params[:widget_order]

      @area.save

      head :ok
    end

    # GET /admin/widgets/1
    # GET /admin/widgets/1.json
    def show
      redirect_to admin_widgets_url
    end

    # GET /admin/widgets/new
    def new
      if params[:type].blank?
        redirect_to admin_widgets_url, notice: 'Please select a valid widget type'
      else
        @widget = Widget.new
        @widget.name = params[:type]
      end
      respond_to do |format|
        format.html
        format.js
      end
    end

    # GET /admin/widgets/1/edit
    def edit
      respond_to do |format|
        format.html
        format.js { render layout: false }
      end
    end

    # POST /admin/widgets
    # POST /admin/widgets.json
    def create
      @widget = Widget.new(widget_params)

      respond_to do |format|
        if @widget.save

          RequestStore.store[:campaign_current] = Campaign.find widget_params[:campaign_id] if widget_params[:campaign_id].present?

          update_amazon_s3

          format.html { redirect_to admin_widgets_url(campaign: widget_params[:campaign_id]), notice: 'Widget was successfully created.' }
          format.json { render action: 'show', status: :created, location: @widget }
          format.js { render layout: false }
        else
          format.html { render action: 'new' }
          format.json { render json: @widget.errors, status: :unprocessable_entity }
          format.js { render layout: false }
        end
      end
    end

    # PATCH/PUT /admin/widgets/1
    # PATCH/PUT /admin/widgets/1.json
    def update
      respond_to do |format|
        if @widget.update(widget_params)

          RequestStore.store[:campaign_current] = Campaign.find widget_params[:campaign_id] if widget_params[:campaign_id].present?

          update_amazon_s3

          format.html { redirect_to admin_widgets_url(campaign: widget_params[:campaign_id]), notice: 'Widget was successfully updated.' }
          format.json { head :no_content }
          format.js { render layout: false }
        else
          format.html { render action: 'edit' }
          format.json { render json: @widget.errors, status: :unprocessable_entity }
          format.js { render layout: false }
        end
      end
    end

    # DELETE /admin/widgets/1
    # DELETE /admin/widgets/1.json
    def destroy
      @widget.destroy

      url_params = request.referer.split('?')[1]

      if url_params.present?
        campaign_id = url_params.split('=')[1]
        RequestStore.store[:campaign_current] = Campaign.find campaign_id
      end

      respond_to do |format|
        format.html { redirect_to admin_widgets_url(campaign: widget_params[:campaign_id]) }
        format.json { head :no_content }
        format.js { render layout: false }
      end
    end

    private

    def purge_proxy_cache
      CacheService.new(Site.current).purge(url_for(send("root_#{Site.current.id}_url")))

      campaign = if @widget.try(:campaign).present?
        @widget.campaign
      elsif @area.try(:campaign).present?
        @area.campaign
      end

      return if campaign.blank?

      urls = []
      urls << dynamic_url_for('campaigns', 'show', slug: campaign.slug, host: campaign.site.hostname, only_path: false)
      urls << dynamic_campaign_url_for(campaign) if campaign.is_root_campaign?

      CacheService.new(campaign.site).purge(urls)
    end

    # save those variables so that we dont serialize the whole Http::Fileupload object
    def set_upload_variables
      Widget::UPLOADABLE_VALUES.each do |value|
        (@uploads ||= []) << {
          value.to_sym => widget_params[value.to_sym]
        } if widget_params[value.to_sym].present?

        (@removes ||= []) << {
          value.to_sym => widget_params["remove_#{value.to_sym}"]
        } if widget_params["remove_#{value.to_sym}"] == '1'

        params[:widget].delete(value.to_sym)
        params[:widget].delete("remove_#{value.to_sym}")
      end
    end

    def update_amazon_s3
      if @removes.present?
        @removes.each do |r|
          remove_image(r.keys.first)
          @widget.value.send("#{r.keys.first}=", nil)
          @widget.value.send("#{r.keys.first}_url=", nil)
          @widget.save
        end

      elsif @uploads.present?
        @uploads.each do |image|
          url = upload_image(image)
          next unless url.present?

          @widget.value.send("#{image.keys.first}=", File.basename(url))
          @widget.value.send("#{image.keys.first}_url=", url)
          @widget.save
        end
      end
    end

    def remove_image(image_name)
      @widget.delete_from_bucket SettingUploader.new, image_name
    end

    def upload_image(image)
      uploader = @widget.upload_to_bucket SettingUploader.new, image.values.first, image.keys.first
      uploader.url || false
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_widget
      @widget = Widget.find_by(id: params[:id], site_id: Site.current.id) || not_found
    end

    # checks if the current changes are to be done for a special campaign
    def check_presence_of_campaign
      # either campaign is set in params
      if params.key? :campaign
        Campaign.current = Campaign.where(id: params[:campaign]).first
        if Campaign.current.blank?
          redirect_to admin_widgets_url, notice: 'Please select a valid campaign'
        end

      # or campaign is already assigned to the current widget
      elsif @widget.present? and @widget.campaign_id.present?
        Campaign.current = Campaign.find(@widget.campaign_id)

      # else work without a current campaign
      else
        Campaign.current = nil
      end

      @campaign_id = Campaign.current ? Campaign.current.id : nil
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def widget_params
      params.require(:widget).permit(
        :title,
        :header_color,
        :header_icon,
        :css_class,
        :columns,
        :without_header,
        :show_in_categories,
        :show_in_shops,
        :transparent_widget,
        :columns,
        :tag,
        :type,
        :href,
        :alt,
        :teaser_links,
        :custom_style,
        :placeholder,
        :button_text,
        :image,
        :redirection_url,
        :limit,
        :content,
        :image,
        :remove_image,
        :tracking_name,
        :popup_start_date,
        :popup_end_date,
        :popup_interval,
        :name,
        :value,
        :order_by,
        :order_direction,
        :widget_order,
        :area,
        :campaign_id,
        :amount,
        :image_url,
        :delay,
        :tag_line,
        :gap_filler,
        :subtitle,
        :background_url,
        :mobile_background_url,
        :logo_url,
        :contact_emails,
        :name_placeholder,
        :email_placeholder,
        :extra_field_placeholder,
        :clickout_url,
        :success_modal_text,
        :newsletter_signup,
        :newsletter_mailchimp_list,
        :ad_code,
        :images,
        :category,
        :shop,
        :coupon_ids,
        :featured_coupons_type,
        :background_color,
        :countdown_date,
        :show_countdown,
        :rss_feed_url,
        :post_count,
        :shop_list_title,
        :shop_list_columns,
        :section_one_header,
        :section_two_header,
        :width,
        :rotated_coupon_ids,
        shop_list_shops:[],
        coupons: [],
        show_in_categories: [],
        show_in_shops: [],
        images: [
          :url,
          :src,
          :title,
          :overlay_color
        ],
        shops: [],
        categories: [],
        tags: [],
        teaser_positions: [],
        hot_offers: [
          :label_color,
          :size,
          :box_type,
          :image,
          :text_alignment,
          :logo_bg_color,
          :coupon_ids,
          :hide_logo,
          :logo_bg_transparent,
        ],
        subpage_teaser: [
          :title,
          :url,
          :image_url,
          :icon_url
        ],
        premium_hero: [
          :coupon_ids,
          :clickout_url
        ],
        premium_offer_rows: [
          widgets: [
            :type,
            :background_url,
            :background_color,
            :background_opacity,
            :background_position,
            :headline,
            :content,
            :category_name,
            :category_color,
            :coupon_id,
            :cta_style,
            :cta_text,
            :url
          ]
        ],
        top_sales: [
          :title,
          :coupon_id,
          :image_url
        ],
        discount_bubbles: [
          :coupon_id,
          :image_url
        ],

      )
    end
  end
end
