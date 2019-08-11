namespace :insecure_content do

  desc "Filters out insecure content from shop seo texts"

  task :filter => :environment do |t, args|

    ssl_sites = [1, 2,3,4,6,8,9]

    ssl_sites.each do |id|
      site = Site.find(id)

      # site.shops.each do |shop|
      #   puts shop.slug
      #   puts shop.id

      #   changed = {}

      #   begin
      #     if shop.html_document.content.present?
      #       clean_content = remove_insecure_content(shop.html_document.content)
      #       if clean_content.present? && clean_content != shop.html_document.content
      #         shop.html_document.update_attribute(:content, clean_content)
      #       end
      #     end

      #   rescue Exception => e
      #     next
      #   end
      # end


      site.campaigns.each do |campaign|
        puts campaign.slug
        puts campaign.id

        changed = {}

        begin
          if campaign.html_document.content.present?
            clean_content = remove_insecure_content(campaign.html_document.content)
            if clean_content.present? && clean_content != campaign.html_document.content
              campaign.html_document.update_attribute(:content, clean_content)
            end
          end

          if campaign.text.present?
            clean_description = remove_insecure_content(campaign.text)
            if clean_description.present? && clean_description != campaign.text
              campaign.update_attribute(:text, clean_description)
            end
          end

        rescue Exception => e
          next
        end
      end

      site.static_pages.each do |page|
        puts page.slug
        puts page.id
        begin
          if page.html_document.content.present?
            clean_content = remove_insecure_content(page.html_document.content)
            if clean_content.present? && clean_content != page.html_document.content
              page.html_document.update_attribute(:content, clean_content)
            end
          end
        rescue Exception => e
          next
        end
      end
    end
  end

  def remove_insecure_content content

    ssl_hosts = [
      'cupon.es',
      'cupom.com',
      'cupon.com.co',
      'cupon.cl',
      'tuscupones.com.mx',
      'sconti.com',
      'kupon.pl',
    ]
    replace_hosts = [
      'http://cdn.couponcrew.net',
      'http://assets.couponcrew.net',
      'https://cdn.couponcrew.net',
      'https://pannacotta-production.s3.amazonaws.com',
      'http://pannacotta-production.s3.amazonaws.com',
      'http://js-1000-assets-production.jetscale.net',
    ]

    doc = Nokogiri::XML.fragment(content)

    if doc.search('img').present?
      doc.search('img').each do |img|
        if img['src'].present? && ssl_hosts.any? { |host| img['src'].start_with?("http://#{host}") }
          img['src'] = img['src'].gsub("http://", "https://")
        elsif img['src'].present? && replace_hosts.any? { |host| img['src'].start_with?(host) }
          str = img['src']
          replace_hosts.each {|replacement| str.gsub!(replacement, 'https://js-1000-assets-production.jetscale.net')}
          img['src'] = str
        else
          img.remove
        end
      end
    end

    if doc.search("script").present?
      doc.search("script").each do |script|
        script.remove
      end
    end

    # remove empty links (after images are deleted some AN links might be empty)
    doc.search('a').find_all{|node| node.children.all?{|child| child.blank? }  }.each {|a| a.remove }

    out = doc.to_html

    # replace internal links
    ssl_hosts.each {|replacement| out.gsub!("http://#{replacement}", "https://#{replacement}")}

    return out
  end
end
