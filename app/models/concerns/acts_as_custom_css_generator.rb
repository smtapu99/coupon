module ActsAsCustomCssGenerator
  extend ActiveSupport::Concern

  included do

    after_save :compile_scss, if: -> { Setting.style_changed == true || Setting.image_upload_changed == true }

    def compile_scss
      return false if self.style.blank? || self.style.styles_enabled.to_i.zero? || style.theme.blank?

      set_last_compiled_at and reset_setting_globals

      compiled = compile_theme style.theme

      return compiled
    end

    def compile_theme theme
      return false unless ['flat_2016', 'rebatly_flat'].include?(theme)

      # create new themes folder if it doesnt exist
      app_themes_dir = Rails.root.join('app', 'themes', theme, 'assets', 'stylesheets', theme)
      save_path = asset_path(site.host_to_file_name, theme)
      sass_load_paths = ['.', app_themes_dir, Rails.root.join('vendor', 'assets', 'stylesheets')]
      theme_style_file  = File.join(app_themes_dir, 'all.scss.erb')

      # fetch default pannacotta styles and import the newly created variables file
      namespace = OpenStruct.new({variables: concat_style_variables(theme), theme: theme})

      sass_template = ERB.new(
        File.read(theme_style_file)
      ).result(namespace.instance_eval {binding})

      File.open(save_path, 'w') do |f|
        f.write(
          AutoprefixerRails.process(
              ::Sass::Engine.new(sass_template, {
              cache: false,
              load_paths: sass_load_paths,
              read_cache: false,
              style: :compressed,
              syntax: :scss,
              :sprockets => {
                :context => ActionView::Base.new,
                :environment => Rails.application.assets
              }
            }).render
          )
        )
      end

      if upload_to_cdn(save_path) == [:store_versions!]
        self.update_column(:value, self.value)
        return true
      end
      return false

    end

    # creates a given directory if not exists and returns the dir path
    # @param  dir [String] directory path
    #
    # @return [String] directory path
    def assure_dir(dir)
      if File.directory?(dir)
        dir
      else
        FileUtils.mkdir_p(dir).first
      end
    end

    def upload_to_cdn asset_path
      uploader = Admin::AssetUploader.new
      uploader.store!(File.open(asset_path))
    end

    def reset_setting_globals
      Setting.style_changed = false if Setting.style_changed
      Setting.image_upload_changed = false if Setting.image_upload_changed
    end

    def set_last_compiled_at
      self.value.style.last_compiled_at = Time.zone.now.to_i.to_s
    end

    def concat_style_variables theme
      styles = self.style.marshal_dump.except(:last_compiled_at) if self.style.is_a? OpenStruct

      variables = ''
      styles.each do |k, v|
        next if v.blank? || !theme_var_allowed?(theme, k)
        v = sanitize_value k, v
        variables += "$#{k.to_s.gsub('_', '-')}:\t\t\t#{v};\n" if v.present?
      end if theme.present?
      variables
    end

    def theme_var_allowed? theme, key
      vars = case theme.to_s
      when 'flat_2016', 'rebatly_flat'
        [
          :color_text,
          :color_headline,
          :color_cloud,
          :color_ready,
          :color_sky,
          :color_royal,
          :color_freedom
        ]
      end

      [*vars].include?(key.to_sym)
    end

    def sanitize_value(k, v)
      v = '$color-'+ v if Option::OPTIONS[:background_default_color_names].values.include? v
      v = v + 'px'  if k.to_s == 'container_desktop'
      v = '"' + v.chomp('/') + '/assets/' +'"' if k.to_s == 'image_base_url' # put quotes, delete trailing slashes and add '/assets/'
      v
    end

    def asset_path(digest, theme)
      dir = assure_dir Rails.root.join("public/pc/assets/themes/#{digest}/")
      return dir.to_s + "#{self.stylesheet_filename(theme)}"
    end
  end
end
