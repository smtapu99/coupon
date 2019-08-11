namespace :recreate_images do

  task shops: :environment do |t, args|
    Parallel.map(Shop.where('updated_at > "2016-08-25 00:00:00"').all, in_process: 6) do |shop|
      puts "site: #{shop.site_id.to_s}: shop #{shop.id.to_s}"
      begin
        shop.header_image.recreate_versions! if shop.header_image_url.present?
        shop.logo.recreate_versions! if shop.logo_url.present?
      rescue Exception => e
        raise e
      end
    end
  end

  task media: :environment do |t, args|
    Parallel.map(Medium.where('updated_at > "2016-08-25 00:00:00"').all, in_process: 6) do |medium|
      begin
        puts "site: #{medium.site_id.to_s}: medium #{medium.id.to_s}"
        medium.file_name.recreate_versions! if medium.file_name.present?
      rescue Exception => e
        next
      end
    end
  end

  task categories: :environment do |t, args|

  end

  task slides: :environment do |t, args|
    Parallel.map(Slide.all, in_process: 6) do |slide|
      begin
        puts "slide #{slide.id.to_s}"
        slide.src.recreate_versions! if slide.src_url.present?
      rescue Exception => e
        puts 'error in slide: ' + slide.id.to_s
        next
      end
    end
  end

  task campaigns: :environment do |t, args|

  end

end
