namespace :stylesheets do

  desc "Process the stylesheets again for all sites"

  task process_all: :environment do |t, args|

    Site.active.each do |site|
      # set the site for the uploader
      Admin::AssetUploader.set_site(site)
      # update the settings updated_at

      next if site.setting.blank? || site.setting.get('style.styles_enabled', default: 0).to_i == 0

      compiled = site.setting.compile_scss

      if compiled
        puts 'processed stylesheet for ' + site.hostname.to_s
      else
        puts "error processing stylesheet for #{site.hostname}; Check if styles are enabled and theme is within [flat_2016, rebatly_flat]"
        puts site.setting.errors.full_messages if site.setting.errors.present?
      end
    end
  end
end
