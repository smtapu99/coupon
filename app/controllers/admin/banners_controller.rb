require 'vue_data/banner'

module Admin
  class BannersController < BaseController
    before_action :authenticate_admin_user!
    load_and_authorize_resource

    before_action :set_banner, only: [:edit, :update, :destroy]
    before_action :set_shops_and_categories, only: [:new, :create, :edit, :update]

    # GET /admin/banners
    # GET /admin/banners.json
    def index
      respond_to do |format|
        format.json { render json: VueData::Banner.render_json(Site.current.id, params), status: :ok }
        format.html
      end
    end

    # GET /admin/banners/new
    def new
      @banner = Banner.new
      @banner.banner_type = params[:banner_type] || 'sticky_banner'
    end

    # GET /admin/banners/1/edit
    def edit
    end

    # POST /admin/banners
    def create
      @banner = Banner.new(banner_params)
      @banner.site_id = Site.current.id

      respond_to do |format|
        if @banner.save
          format.html { redirect_to admin_banners_url, notice: 'Banner was successfully created.' }
        else
          format.html { render action: 'new' }
        end
      end
    end

    # PATCH/PUT /admin/banners/1
    def update
      respond_to do |format|
        if @banner.update(banner_params)
          format.html { redirect_to admin_banners_url, notice: 'Banner was successfully updated.' }
        else
          format.html { render action: 'edit' }
        end
      end
    end

    # DELETE /admin/banner/1
    # DELETE /admin/banner/1.json
    def destroy
      @banner.destroy
      respond_to do |format|
        format.json { head :no_content }
      end
    end

    private

    def set_shops_and_categories
      @shops = Site.current.shops.active.order(title: :asc)
      @categories = Site.current.categories.active.order(name: :asc)
    end

    def set_banner
      @banner = Banner.find(params[:id]) || not_found
    end

    def banner_params
      params.require(:banner).permit(
        :name,
        :banner_type,
        :status,
        :content,
        :show_in_shops,
        :start_date,
        :end_date,
        :theme,
        :caption_heading,
        :caption_body,
        :button_text,
        :target_url,
        :countdown_date,
        :image_url,
        :logo_url,
        :font_color,
        :cta_background,
        :cta_color,
        :href,
        :alt,
        :is_external_url,
        :animate,
        :attach_newsletter_popup,
        :show_on_home_page,
        :excluded_for_mobile_resolution,
        category_ids: [],
        shop_ids: [],
        excluded_shop_ids: []
      )
    end
  end
end
