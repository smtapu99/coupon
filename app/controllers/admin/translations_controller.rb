module Admin
  class TranslationsController < BaseController
    before_action :authenticate_admin_user!
    load_and_authorize_resource

    before_action :set_translation, only: [:edit, :update, :destroy]

    def index
      @translations = Translation.by_site(Site.current).order(created_at: :desc)

      if params[:search].present?
        @translations = @translations.by_search_query(params[:search])
      end
    end

    def new
      @translation = Translation.new
    end

    def edit
    end

    def update
      respond_to do |format|
        if @translation.update(translation_params)
          format.html { redirect_to admin_translations_url, notice: 'Translation was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @translation.errors, status: :unprocessable_entity }
        end
      end
    end

    def create
      @translation = Translation.new(translation_params)
      respond_to do |format|
        if @translation.save
          format.html { redirect_to admin_translations_url, notice: 'Translation was successfully created.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @translation.errors, status: :unprocessable_entity }
        end
      end
    end

    def export_keys
      @keys = Translation.distinct_keys
      render 'export_keys', formats: :xlsx, layout: false
    end

    def destroy
      notice = "#{@translation.key} deleted!"
      @translation.destroy
      redirect_to admin_translations_path, :notice => notice
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_translation
      @translation = Translation.find_by(id: params[:id], locale: allowed_locales) || not_found
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def translation_params
      if Site.current
        params.require(:translation).permit(:key, :locale, site_custom_translation_attributes: [:id, :value])
      else
        params.require(:translation).permit(:key, :locale, :value)
      end
    end
  end
end
