namespace :calculate_priorities do

  desc "Updates the active_coupons_count column in shops or categories"

  task all: :environment do |t, args|
    Coupon::calculate_priorities
    Shop::calculate_priorities
  end

  task shops: :environment do |t, args|
    Shop::calculate_priorities
  end

  task coupons: :environment do |t, args|
    Coupon::calculate_priorities
  end

end
