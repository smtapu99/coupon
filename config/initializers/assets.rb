# Be sure to restart your server when you modify this file.

### ASSETS LIKE PRODUCTION ###
#Rails.application.config.assets.js_compressor = :uglifier
Rails.application.config.assets.css_compressor = :sass
Rails.application.config.assets.compile = true
Rails.application.config.assets.digest = Rails.env.production?
Rails.application.config.assets.enabled = true
### END ASSETS LIKE PRODUCTION ###

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

if Rails.env.production?
  # store assets in a 'folder' instead of bucket root
  Rails.application.config.assets.prefix = "/pc/assets"
  #config.action_controller.asset_host = "//assets.savings-united.com"
  #Rails.application.config.action_controller.asset_host = "//#{Rails.application.config.custom_services['fog_directory']}"
end

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( admin.js admin.css )
Rails.application.config.assets.precompile += [ Proc.new { |path, fn| fn =~ /app\/themes/ && !%w(.js .css .svg .eot .woff .ttf).include?(File.extname(path)) } ]
Rails.application.config.assets.precompile += Dir["app/themes/*"].map { |path| "#{path.split('/').last}/all.js" }
Rails.application.config.assets.precompile += Dir["app/themes/*"].map { |path| "#{path.split('/').last}/all.scss" }
Rails.application.config.assets.precompile += Dir["app/themes/*"].map { |path| "#{path.split('/').last}/defer.js" }
