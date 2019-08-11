class Site::UpdateStatus::Block

  def self.call site
    site.coupons.update_all(status: 'blocked')
    site.shops.update_all(status: 'blocked')
  end
end
