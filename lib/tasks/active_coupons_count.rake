namespace :active_coupons_count do

  desc "Updates the active_coupons_count column in shops or categories"

  task all: :environment do |t, args|

    pid_file = '/tmp/active_coupons_count_all.pid'
    raise 'pid file exists!' if File.exists? pid_file

    File.open(pid_file, 'w'){|f| f.puts Process.pid}
    begin
        run_all
    ensure
        File.delete pid_file
    end

  end

  def run_all

    sql = "UPDATE shops set active_coupons_count = (select count(*) from coupons where (coupons.start_date is null or coupons.start_date <= NOW()) and (coupons.end_date is null or coupons.end_date >= NOW()) and coupons.status = 'active' and coupons.shop_id = shops.id)"

    ActiveRecord::Base.connection.execute(sql)
    puts 'updated all shops'

    catsql = "UPDATE categories INNER JOIN
      (
      select category_id, count(coupons.id) as count from coupons
      INNER JOIN shops on shops.id = coupons.shop_id
      INNER JOIN `coupon_categories` ON `coupons`.`id` = `coupon_categories`.`coupon_id`
      WHERE `shops`.`status` = 'active' AND `coupons`.`status` = 'active'
      AND (coupons.start_date is null or coupons.start_date <= NOW())
      AND (coupons.end_date is null or coupons.end_date >= NOW())
      GROUP BY category_id
      ) as cat_count on cat_count.category_id = categories.id
     set active_coupons_count = cat_count.count"

    ActiveRecord::Base.connection.execute(catsql)
    puts 'updated all categories'

    # CA-1089 previously this calculation was done within calculate_priorities.rake
    # but due to overlapping scripts we tend to put them together
    Coupon::calculate_priorities
    Shop::calculate_priorities

  end

end
