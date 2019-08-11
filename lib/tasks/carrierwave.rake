namespace :carrierwave do
  desc "Clean out temp CarrierWave files"
  task :clean do
    CarrierWave.clean_cached_files!
    FileUtils.rm_rf Dir.glob("#{Rails.root}/public/uploads/tmp/*")
  end
end
