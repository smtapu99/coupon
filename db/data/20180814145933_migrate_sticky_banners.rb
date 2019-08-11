class MigrateStickyBanners < ActiveRecord::Migration[5.2]
  def up

    # sticky banners
    Site.active.each do |site|
      old = site.try(:setting).try(:banner)
      next unless old.present?

      banner = Banner.find_or_initialize_by(banner_type: 'sticky_banner', site_id: site.id)
      banner.name = 'Default Sticky Banner'
      banner.status = 'inactive' unless old.show_banner == "1"
      banner.theme = old.theme
      banner.image_url = old.default_banner_img_url
      banner.logo_url = old.default_banner_logo_url
      banner.font_color = old.default_banner_font_color
      banner.cta_background = old.default_banner_cta_background
      banner.cta_color = old.default_banner_cta_color
      banner.caption_heading = old.caption_heading
      banner.caption_body = old.caption_body
      banner.button_text = old.button_text
      banner.target_url = old.target_url
      banner.countdown_date = old.countdown_date
      banner.start_date = old.start_date.present? ?  old.start_date : Date.today
      banner.end_date = old.end_date.present? ? old.end_date : Date.today.end_of_year
      banner.save!
    end

    # shop banners
    Site.active.each do |site|
      old = site.try(:setting).try(:shop_banner)
      next unless old.present?

      banner = Banner.find_or_initialize_by(banner_type: 'shop_banner', site_id: site.id)
      banner.name = 'Default Shop Banner'
      banner.status = 'inactive' unless old.show_banner == "1"
      banner.image_url = old.image_url
      banner.target_url = old.target_url
      banner.excluded_shop_ids = old.excluded_shop_ids
      banner.save!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
