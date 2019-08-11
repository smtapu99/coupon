require 'kraken-io'
module CarrierWave
  module PannacottaOptimizer

    def resize_to_limit_by_name(width, height, *names)
      resize_to_limit(width,height) if names.map(&:to_sym).include?(mounted_as.to_sym)
    end

    def resize_to_fit_by_name(width, height, *names)
      resize_to_fit(width,height) if names.map(&:to_sym).include?(mounted_as.to_sym)
    end

    def kraken_optimize(options = {})
      return if Rails.env.test?
      return if self.model.present? && !self.model.send("#{mounted_as}_changed?")

      kraken = Kraken::API.new(
          :api_key => Rails.application.config.custom_services['kraken_api_key'],
          :api_secret => Rails.application.config.custom_services['kraken_api_secret']
      )

      defaults = {
        'lossy' => true,
        'quality' => 90
      }

      options = defaults.merge(options);

      request = kraken.upload(current_path, options)

      if request.success
        File.write(current_path, open(request.kraked_url).read, { :mode => 'wb' })
      end
    end
  end
end
