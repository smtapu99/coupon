
task :change_slugs => :environment do

 urls = [
  ['amica-farmacia','codice-sconto-amica-farmacia'],
  ['apple-store','codice-promozionale-apple-store'],
  ['bang-good','coupon-banggood'],
  ['bernabei-liquori','codice-sconto-bernabei'],
  ['blablacar','bla-bla-car-coupon'],
  ['buono-sconto-bauzaar','codice-sconto-bauzaar'],
  ['carpisa','codice-sconto-carpisa'],
  ['cisalfa-sport-offerte','cisalfa-sport-buono-sconto'],
  ['codice-promo-clarisonic','codice-sconto-clarisonic'],
  ['codice-promozionale-costa-crociere','codice-sconto-costa-crociere'],
  ['codice-promozionale-diadora','codice-sconto-diadora'],
  ['codice-promozionale-duracell','coupon-duracell'],
  ['codice-promozionale-edreams','codice-sconto-edreams'],
  ['codice-promozionale-groupon','codice-sconto-groupon'],
  ['codice-promozionale-my-m-m-s','codice-promozionale-mms'],
  ['codice-promozionale-nike','codice-sconto-nike'],
  ['codice-promozionale-nuance','codice-sconto-nuance'],
  ['codice-promozionale-oregonscientific','codice-sconto-oregon-scientific'],
  ['codice-promozionalef-farmavillage','codice-promozionale-farmavillage'],
  ['codice-sconto-airdolomiti','codice-sconto-air-dolomiti'],
  ['codice-sconto-bottega-verde','coupon-bottega-verde'],
  ['codice-sconto-brusselsairlines','codice-promozionale-brussels-airlines'],
  ['codice-sconto-buyvip','codice-sconto-amazon-buyvip'],
  ['codice-sconto-directline','codice-sconto-direct-line'],
  ['codice-sconto-eachbuyer','eachbuyer-coupon'],
  ['codice-sconto-eglobalcentral','codice-sconto-eglobal-central'],
  ['codice-sconto-fastweb','codice-promozionale-fastweb'],
  ['codice-sconto-ferraristore','codice-sconto-ferrari-store'],
  ['codice-sconto-fratellirossetti','fratelli-rossetti-saldi'],
  ['codice-sconto-gasjeans','gas-jeans-codice-sconto'],
  ['codice-sconto-gearbest','gearbest-coupon'],
  ['codice-sconto-goldenpoint','goldenpoint-saldi'],
  ['codice-sconto-h-m','codice-sconto-hm'],
  ['codice-sconto-hotels-com','codice-sconto-hotels'],
  ['codice-sconto-hudsonreed','codice-sconto-hudson-reed'],
  ['codice-sconto-maseratistore','codice-sconto-maserati-store'],
  ['codice-sconto-silvianheach','codice-sconto-silvian-heach'],
  ['codice-sconto-the-hurry','codice-sconto-hurry'],
  ['codice-sconto-zara','buono-sconto-zara'],
  ['conrad','codice-sconto-conrad'],
  ['coupon-bialetti','codice-sconto-bialetti'],
  ['coupon-chain-reaction-cycles','chain-reaction-cycles-coupon'],
  ['coupon-disneylandparis','coupon-disneyland-paris'],
  ['coupon-europcar','codice-sconto-europcar'],
  ['coupon-lovethesign','codice-sconto-lovethesign'],
  ['coupon-patrizia-pepe','codice-sconto-patrizia-pepe'],
  ['dalani-offerte','codice-sconto-dalani'],
  ['fornarina','codice-sconto-fornarina'],
  ['giordano-shop-offerte','codice-sconto-giordano-shop'],
  ['guess-saldi','codice-sconto-guess'],
  ['hoepli','codice-sconto-hoepli'],
  ['kasanova-offerte','codice-sconto-kasanova'],
  ['l-occitane','codice-sconto-loccitane'],
  ['logitravel','codice-sconto-logitravel'],
  ['mediaset-premium','codice-promozionale-mediaset-premium'],
  ['milan-store','codice-sconto-milan-store'],
  ['miss-sixty','miss-sixty-coupon'],
  ['moleskine','codice-sconto-moleskine'],
  ['noicompriamoauto','codice-sconto-noicompriamoauto'],
  ['north-week','codice-sconto-northweek'],
  ['offerte-avira','coupon-avira'],
  ['offerte-babbel','coupon-babbel'],
  ['offerte-giordano-vini','codice-sconto-giordano-vini'],
  ['offerte-meetic','coupon-meetic'],
  ['offerte-qvc','codice-sconto-qvc'],
  ['opodo','codice-sconto-opodo'],
  ['prozis','coupon-prozis'],
  ['ray-ban','offerte-ray-ban'],
  ['redcoon','codice-sconto-redcoon'],
  ['saldi-superdry','codice-sconto-superdry'],
  ['staples-omaggi','codice-sconto-staples'],
  ['timberland-offerte','codice-sconto-timberland'],
  ['tommyhilfiger-coupon','codice-sconto-tommy-hilfiger'],
  ['tui','codice-sconto-tui'],
  ['uci-cinemas','coupon-uci-cinemas'],
  ['yamamay','codice-sconto-yamamay'],
  ['zalando','codice-sconto-zalando']
 ]

  shops = []
  redirects = []
  campaign_redirects = []
  existing_redirects = []
  existing_campaign_redirects = []
  no_change = []
  blocked_shops = []

  site = Site.find(18)

  urls.each do |slug|
    if slug[0] == slug[1]
      no_change << slug
      next
    end

    begin
      shop = Shop.find_by(slug: slug[0], site_id: site.id, status: 'active')

      unless shop.present?
        blocked_shops << slug
        next
      end

      shop.campaigns.each do |campaign|
        existing_campaign_redirects << shop.current_redirects_for('/codice-sconto' + slug[1] + '/codice-sconto' + campaign.slug, '/' + slug[0] + '/' + campaign.slug)
        rule = RedirectRule.new(
          site_id: site.id,
          source: '/codice-sconto/' + slug[0] + '/' + campaign.slug,
          destination: '/codice-sconto/' + slug[1] + '/' + campaign.slug,
          active: 1,
          request_environment_rules:
          [RequestEnvironmentRule.new(environment_key_name: 'SERVER_NAME',environment_value: site.hostname.dup)]
        );

        campaign_redirects << rule.dup
      end

      abort 'implement campaign parent_id slugs redirects'

      shop.slug = slug[1]
      shop.slug_mutable = 1
      shops << shop

      existing_redirects << shop.current_redirects_for('/codice-sconto/' + slug[1], '/codice-sconto/' + slug[0])

      rule = RedirectRule.new(
        site_id: site.id,
        source: '/codice-sconto/' + slug[0].dup,
        destination: '/codice-sconto/' + slug[1].dup,
        active: 1,
        request_environment_rules:
        [RequestEnvironmentRule.new(environment_key_name: 'SERVER_NAME',environment_value: site.hostname.dup)]
      );

      rule = rule.dup
      redirects << rule

    rescue Exception => e
      binding.pry
    end

  end

  binding.pry

end

# existing_redirects.reject(&:empty?).flatten.map(&:destroy)
# existing_campaign_redirects.reject(&:empty?).flatten.map(&:destroy)
# campaign_redirects.map(&:save)
# redirects.map(&:save)
# shops.map(&:save)
























































































