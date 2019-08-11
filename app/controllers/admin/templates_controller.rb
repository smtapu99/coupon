module Admin
  class TemplatesController < BaseController
    before_action :check_user, on: [:index, :get_layout, :delete_layout, :save]
    before_action :get_option, on: [:index, :get_layout, :delete_layout, :save]
    after_action  :clear_templates_cache, on: [:save, :delete_layout, :restore_default]
    before_action :validate_super_admin


    def index
      authorize! :use_template, Setting
    end

    # POST /admin/templates/save
    def save
      authorize! :use_template, Setting

      if @option.blank?
        @option = Option.create(name: template_type, site_id: Site.current.id, value: params[:value]) if Site.current
      else
        @option.update(value: params[:value])
      end

      head :ok
    end

    def get_layout
      authorize! :use_template, Setting

      respond_to do |format|
        format.js { render :plain => value_or_empty_string }
      end
    end

    def delete_layout
      authorize! :use_template, Setting

      @option.destroy if @option.present?
      head :ok
    end

    # restores template defaults
    # e.g. if template type == custom_layout get the default from a file
    #
    #
    def restore_default
      authorize! :use_template, Setting

      if @option.present?
        if template_type == 'custom_layout'
          @option.update(value: default_custom_layout)
        else
          @option.destroy
        end
      end

      respond_to do |format|
        format.js { render plain: default_template }
      end
    end

    private

    def clear_templates_cache
      Option.clear_templates_cache
    end

    def generate_default_layout_from_file
      Option.create(name: 'custom_layout', site_id: Site.current.id, value: default_custom_layout) if Site.current
    end

    def default_custom_layout
      File.read("app/views/layouts/frontend_layout_body.html.erb")
    end

    def get_option
      @option = Option.where(name: template_type, site_id: Site.current.id).first if Site.current
    end

    def template_type
      case params[:template]
      when 'hs'
        'head_script'
      when 'bs'
        'body_script'
      when 'fs'
        'footer_script'
      when 'mcl'
        'mobile_custom_layout'
      else
        'custom_layout'
      end
    end

    def value_or_empty_string
      @option.present? ? @option.value.to_s : ''
    end

    def default_template
      case template_type
      when 'custom_layout'
        default_custom_layout
      else
        ''
      end
    end

    def check_user
      redirect_to new_admin_user_session_path unless User.current.present?
    end
  end
end
