require 'csv'

namespace :bi do

  def category_related_shops_by_tier(categories, tier, limit = 5, shop)
    (categories.map {|c| c.related_shops.active.with_active_coupons.by_tier_group(tier).where("relation_to_id != ?", shop.id).select('shops.id').order(priority_score: :desc)}).flatten.uniq.take(limit)
  end

  task find_broken_urls: :environment do |t, args|
    BrokenUrlsChecker::run
  end

  task related_shops: :environment do |t, args|
    data = []
    Site.where(country_id: 13).active.each do |site|
      site.shops.active.each do |shop|
        top_categories = shop.relevant_categories

        if top_categories.present?
          # if shop.tier_group > 1
          #   popular_shops = category_related_shops_by_tier(top_categories, shop.tier_group, 15, shop)
          # end
          related_shops = category_related_shops_by_tier(top_categories, shop.tier_group, 15, shop)
          data += related_shops.map {|ps| [site.id, shop.id, ps.id] }
        end
      end
    end

    CSV.open("related_shops.csv", "w") do |csv|
      csv << ["Site ID", "Source Shop", "Target Shop"]
      data.each do |data|
        csv << data
      end
    end
  end

  task widgets_in_use: :environment do |t, args|
    campaign_ids = Campaign.where(status: 'active').pluck(:id)
    types = WidgetArea.where("campaign_id is null or campaign_id in (?)", campaign_ids).map do |area|
      area.widgets.map(&:name)
    end.flatten.uniq

    types
    binding.pry
  end
end
