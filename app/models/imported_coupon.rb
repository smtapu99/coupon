class ImportedCoupon < Coupon
  validate :shop_active?
  has_statuses(
    active: 'active',
    blocked: 'blocked',
    pending: 'pending'
  )
  # Returns allowed import parameter
  #
  # @return [Array] allowed import parameter
  def self.allowed_import_params
    [
      'Title',
      'Status',
      'URL',
      'Logo',
      'Code',
      'Description',
      'Type',
      'Image URL',
      'Widget Header URL',
      'Affiliate Network Slug',
      'Category Slug',
      'Campaign Slug',
      'Shop Slug',
      'Is Exclusive?',
      'Is Editors Pick?',
      'Is Free?',
      'Is Free Delivery?',
      'Is Mobile?',
      'Is Top?',
      'Savings',
      'Savings In',
      'Currency',
      'Logo Text First Line',
      'Logo Text Second Line',
      'Start Date',
      'End Date',
      'Shop List Priority',
      'Coupon ID',
      'Use Uniq Codes',
      'Is Hidden?',
      'Info Discount',
      'Info Min Purchase',
      'Info Limited Clients',
      'Info Limited Brands',
      'Info Conditions',
      'Site ID'
    ]
  end

  private

  def shop_active?
    errors.add :shop, 'is not active.' if shop.present? && shop.status == 'blocked'
  end

end
