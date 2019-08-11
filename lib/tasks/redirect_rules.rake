include Rails.application.routes.url_helpers

require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

namespace :redirect_rules do
  desc "select redirect rules which can be destoyed"
  task select_rules_to_destroy: :environment do
    @deleting_rules = []

    Site.all.each do |site|
      Site.current = site
      @site = SiteFacade.new(site)
      shop_urls = []
      shop_urls << Shop.all.collect{ |shop| send("shop_show_#{site.id}_path", {slug: shop.slug} ) }
      shop_urls << Category.all.collect{ |cat| send("category_show_#{site.id}_path", {slug: cat.slug} ) }
      shop_urls << Category.all.collect{ |cat| cat.parent.present? ? send('dynamic_url_for', 'category', 'show', {slug: cat.parent.slug} ) : nil }
      shop_urls << Campaign.all.collect{ |camp| send("campaign_show_#{site.id}_path", {slug: camp.slug} ) }
      shop_urls << Campaign.all.collect{ |camp| send("dynamic_campaign_url_for", camp, {only_path: true} )}

      shop_urls.flatten!.reject!(&:blank?)

      @deleting_rules << RedirectRule.find_all_by_source_and_destination(shop_urls.flatten, send("root_#{site.id}_path"))

      @deleting_rules.flatten!.uniq!
    end

    puts "#{@deleting_rules.inspect}"
    puts "#{@deleting_rules.count}"
  end

  desc "destroy unnecessary redirect rules"
  task destroy_selected_rules: :environment do
    Rake::Task["redirect_rules:select_rules_to_destroy"].invoke
    puts "#{@deleting_rules.count} should be destroyed"
    @deleting_rules.each do |rule|
      RedirectRule.find(rule.id).destroy
    end
  end


end
