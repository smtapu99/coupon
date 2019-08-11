namespace :alerts do
  task generate: :environment do
    AlertService::check_coupons_expiring
    AlertService::check_uniq_codes_empty
    AlertService::CheckHomepageCouponsExpiring.call
  end
end
