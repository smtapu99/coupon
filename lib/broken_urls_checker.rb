class BrokenUrlsChecker
  # Number of days after which a already solved Problem should be checked again
  # set 'nil' for NEVER CHECK AGAIN
  # RECHECK_SOLVED_AFTER_DAYS = 7
  IN_GROUPS_OF = 10
  IN_THREADS = 8

  def self.run
    new().run
  end

  def run
    Site.active.where('sites.id > 77').each do |site|
      Parallel.each(urls_to_validate(site), in_threads: IN_THREADS) do |urls|
        run_parallel(urls, site)
      end
    end
  end

  private

  def run_parallel(urls, site)
    valid_urls = []
    invalid_urls = []
    urls.each do |url|
      p url.to_s
      begin
        if LinkScout::run(url)
          valid_urls << url
        else
          invalid_urls << url
        end
      rescue StandardError => e
        invalid_urls << url
      end
    end
  ensure
    CSV.open("invalid_urls.csv", "a+") do |csv|
      invalid_urls.each do |data|
        csv << [site.id, data]
      end
    end if invalid_urls.present?
  end

  def urls_to_validate(site)
    query = Coupon.active
                  .joins(:shop)
                  .to_validate
                  .where('shops.tier_group = 1')
                  .where('coupons.url IS NOT NULL and coupons.url != ""')
                  .where(coupons: { site_id: site.id })
                  .group(:url)

    # if RECHECK_SOLVED_AFTER_DAYS.present?
    #   solved_urls = solved_problem_urls(site)
    #   query = query.where('coupons.url not in (?)', solved_urls) if solved_urls.present?
    # end

    query.pluck(:url).in_groups_of(IN_GROUPS_OF)
  end

  # def save_alerts(invalid_urls, site)
  #   Coupon.active.where(url: invalid_urls).each do |coupon|
  #     Alert.create(
  #       alertable_type: 'Coupon',
  #       alertable_id: coupon.id,
  #       alert_type: 'broken_url',
  #       message: 'URL is broken'
  #     )
  #   end
  # end

  # def solved_problem_urls(site)
  #   Problem.where(site_id: site.id)
  #          .where('solved_at > ?', Time.zone.now - RECHECK_SOLVED_AFTER_DAYS.days)
  #          .pluck(:value)
  # end
end
