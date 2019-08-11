require 'rake'

module ActsAsFaviconGenerator
  extend ActiveSupport::Concern

  included do
    after_save :generate_favicon, if: -> { favicon_uploaded? && !Rails.env.test? }

    private

    def generate_favicon
      begin
        cleanup_local
        create_favicon_config_file('favicon.json', 'config')
        Rails::Generators.invoke('favicon')
        create_favicon_config_file('site.webmanifest', 'app/assets/images/favicon')
        create_favicon_config_file('browserconfig.xml', 'app/assets/images/favicon')
        cleanup_erb_files
        upload_files_with_fog
      rescue Exception => e
        # to make sure the shared/favicon.html.erb only gets rendered if the processing worked
        remove_favicon!
        save
      end
    end

    def fog_storage
      @fog_storage ||= Fog::Storage.new(CarrierWave::Uploader::Base.fog_credentials)
    end

    def remove_favicon?
      remove_favicon.present?
    end

    def favicon_uploaded?
      favicon.cached?.present?
    end

    def cached_favicon_url
      favicon.cache_path
    end

    def favicon_bucket_directory
      CarrierWave::Uploader::Base.fog_directory + "/favicons/" + site_id.to_s
    end

    def upload_files_with_fog
      Dir.glob(Rails.root.join('app/assets/images/favicon/*')) do |file|
        fog_storage.put_object(favicon_bucket_directory, File.basename(file), File.read(file))
      end
    end

    def create_favicon_config_file(type, dir)
      FileUtils.mkdir_p(Rails.root.join(dir))

      namespace = OpenStruct.new(setting: self, site: self.site)
      json = ERB.new(
        File.read(Rails.root.join('lib/generators/favicon_generator/' + type))
      ).result(namespace.instance_eval {binding})

      File.open(dir + '/' + type,'w') do |f|
        f.write(json)
      end
    end

    # TODO: Find a cleaner way to remove the whole directory
    # https://github.com/fog/fog-google/
    def cleanup_bucket
      fog_storage.delete_object(favicon_bucket_directory, 'android-chrome-192x192.png') rescue nil
      fog_storage.delete_object(favicon_bucket_directory, 'android-chrome-256x256.png') rescue nil
      fog_storage.delete_object(favicon_bucket_directory, 'apple-touch-icon.png') rescue nil
      fog_storage.delete_object(favicon_bucket_directory, 'browserconfig.xml') rescue nil
      fog_storage.delete_object(favicon_bucket_directory, 'favicon-16x16.png') rescue nil
      fog_storage.delete_object(favicon_bucket_directory, 'favicon-32x32.png') rescue nil
      fog_storage.delete_object(favicon_bucket_directory, 'favicon.ico') rescue nil
      fog_storage.delete_object(favicon_bucket_directory, 'mstile-144x144.png') rescue nil
      fog_storage.delete_object(favicon_bucket_directory, 'mstile-150x150.png') rescue nil
      fog_storage.delete_object(favicon_bucket_directory, 'safari-pinned-tab.svg') rescue nil
      fog_storage.delete_object(favicon_bucket_directory, 'site.webmanifest') rescue nil
    end

    def cleanup_erb_files
      FileUtils.rm_rf('app/assets/images/favicon/site.webmanifest.erb')
      FileUtils.rm_rf('app/assets/images/favicon/browserconfig.xml.erb')
    end

    # cleanup after rails g favicon invokation
    def cleanup_local
      FileUtils.rm_rf('config/favicon.json')
      FileUtils.rm_rf('config/initializers/web_app_manifest.rb')
      FileUtils.rm_rf('app/assets/images/favicon')
      FileUtils.rm_rf('app/views/application/_favicon.html.erb')
      FileUtils.rm_rf('config/favicon.json')
    end
  end
end
