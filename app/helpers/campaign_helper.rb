module CampaignHelper

  def campaign_grid_initial_size(campaign)
    size = campaign.priority_coupon_ids_array.count
    return size - (size % 4) if size > 12
    12
  end

  def campaign_hero_cta(campaign)
    html = campaign.html_document

    if html.present?
      text = html.header_cta_text
      link = html.header_cta_anchor_link
    end

    text = text.present? ? text : t(:hero_cta, default: 'Get it!')
    link = link.present? ? link : '#deals'

    cloak_urls(link_to(text, link, class: 'btn hero__cta')).html_safe
  end
end
