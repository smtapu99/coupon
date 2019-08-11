require 'vue_data/category'

module Admin
  class CategoriesController < BaseController
    include ActsAsActiveCouponsCounter

    before_action :authenticate_admin_user!
    load_and_authorize_resource

    # before_action :set_category, only: [:show, :edit, :update, :destroy]
    before_action :set_category, only: [:edit, :update]

    # GET /admin/categories
    # GET /admin/categories.json

    def index
      respond_to do |format|
        format.html
        format.json { render json: ::VueData::Category.render_json(Site.current.id, params), status: :ok }
      end
    end

    # GET /admin/categories/new
    def new
      @category = Category.new
    end

    # GET /admin/categories/1/edit
    def edit
    end

    # POST /admin/categories
    # POST /admin/categories.json
    def create
      @category = Category.new(category_params)
      respond_to do |format|
        if @category.save
          @category.update_active_coupons_count
          @category.purge_table_key

          format.html { redirect_to admin_categories_url, notice: 'Category was successfully created.' }
          format.json { render action: 'index', status: :created, location: @category }
        else
          format.html { render action: 'new' }
          format.json { render json: @category.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /admin/categories/1
    # PATCH/PUT /admin/categories/1.json
    def update
      @category.related_tier_1_shop_ids = [] if category_params[:related_tier_1_shop_ids].present?
      @category.related_tier_2_shop_ids = [] if category_params[:related_tier_2_shop_ids].present?
      @category.related_tier_3_shop_ids = [] if category_params[:related_tier_3_shop_ids].present?
      @category.related_tier_4_shop_ids = [] if category_params[:related_tier_4_shop_ids].present?

      @category.slug_mutable = 1 if User.current.is_admin?
      respond_to do |format|
        if @category.update(category_params)
          @category.purge_resource_key

          format.html { redirect_to admin_categories_url, notice: 'Category was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @category.errors, status: :unprocessable_entity }
        end
      end
    end

    # GET /admin/categories/order
    def order
      @categories = Site.current.categories.main_category.order(order_position: :asc)
    end

    def update_order
      params[:order_position].each do |position|
        category = Category.find(position[0])
        category.update_attribute(:order_position, position[1]) if category.present?
      end
      @categories = Site.current.categories.order(order_position: :asc)
      render :order
    end

    # GET /admin/categories/change_status
    def change_status
      @params = request.params
      @ids = @params[:ids]

      @ids.each do |id|
        @category = Category.find(id)
        @category.update_attribute(:status, @params[:status])
        @category.purge_resource_key
      end

      render json: @params.to_json
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.find_by(id: params[:id], site_id: Site.current.id) || not_found
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      params.require(:category).permit(
        :css_icon_class,
        :name,
        :description,
        :slug,
        :ranking_value,
        :site_id,
        :origin_id,
        :created_at,
        :updated_at,
        :status,
        :main_category,
        :parent_id,
        :order_position,
        related_shop_ids: [],
        related_tier_1_shop_ids: [],
        related_tier_2_shop_ids: [],
        related_tier_3_shop_ids: [],
        related_tier_4_shop_ids: [],
        html_document_attributes: [
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
          :head_scripts
        ]
      )
    end
  end
end
