class Category < ApplicationRecord
  include ActAsEdgeCachable
  include ActsAsSiteable
  include ActsAsSluggable
  include ActsAsStatusable
  has_statuses(
    active: 'active',
    pending: 'pending',
    blocked: 'blocked',
    gone: 'gone'
  )

  attr_accessor :custom_header_image

  # Relations
  has_many :coupon_categories
  has_many :coupons, through: :coupon_categories
  has_many :shops, -> { distinct }, through: :coupons

  has_many :shop_category_relations, class_name: 'ShopCategory'
  has_many :shops_by_shop_category, through: :shop_category_relations, source: :shop

  has_one :html_document, as: :htmlable, dependent: :destroy
  has_many :banner_locations, as: :bannerable, dependent: :destroy

  has_many :relations_to, as: :relation_from, dependent: :destroy, class_name: 'Relation'
  has_many :related_shops, -> { order('relations.id ASC') }, through: :relations_to, class_name: 'Shop', source: :relation_to, source_type: 'Shop'

  has_many :related_tier_1_shops, -> { where('shops.tier_group'  => '1').order('relations.id ASC') }, through: :relations_to, class_name: 'Shop', source: :relation_to, source_type: 'Shop'
  has_many :related_tier_2_shops, -> { where('shops.tier_group'  => '2').order('relations.id ASC') }, through: :relations_to, class_name: 'Shop', source: :relation_to, source_type: 'Shop'
  has_many :related_tier_3_shops, -> { where('shops.tier_group'  => '3').order('relations.id ASC') }, through: :relations_to, class_name: 'Shop', source: :relation_to, source_type: 'Shop'
  has_many :related_tier_4_shops, -> { where('shops.tier_group'  => '4').order('relations.id ASC') }, through: :relations_to, class_name: 'Shop', source: :relation_to, source_type: 'Shop'

  has_many :sub_categories, foreign_key: :parent_id, class_name: 'Category'

  belongs_to :parent, class_name: 'Category'

  delegate :name, :slug, to: :parent, allow_nil: true, prefix: true

  # Nested Attributes
  accepts_nested_attributes_for :html_document, update_only: true

  # Validation
  validates_presence_of :name, :slug
  validates_presence_of :main_category, if: -> { parent_id.blank? }, message: 'Please mark as Main Category if no Parent Category is selected'
  validates_presence_of :parent_id, if: -> { main_category.blank? }, message: 'Please select Parent Category if current Category is not Main Category'

  validate :subcategory_is_not_main_category

  # Scopes
  scope :indexed, -> { includes(:html_document).references(:html_document).where.not("html_documents.meta_robots like '%noindex%'") }
  scope :active, -> { where(status: 'active') }
  scope :main_category, -> { where(main_category: 1) }
  scope :with_icon, -> { where('css_icon_class is not null and css_icon_class != ""') }
  scope :by_coupon_ids, -> { includes(:coupon_categories).where(coupon_categories: { coupon_id: coupon_ids }) }

  def self.order_by_set(set)
    if set.present?
      order(Arel.sql("find_in_set(categories.id, '#{set.reject(&:blank?).join(',')}')"))
    else
      order('categories.id DESC')
    end
  end

  def self.grid_filter(params)
    query = where(site_id: params[:site_id])
    if params[:parent].present?
      parents = query.where('name like ?', "%#{params[:parent]}%")
      query = query.where(parent_id: parents.map(&:id)) if parents.present?
    end
    query = query.where(id: params[:id]) if params[:id].present?
    query = query.where(status: params[:status]) if params[:status].present?
    query = query.where('name like ?', "%#{params[:name]}%") if params[:name].present?
    query = query.where('slug like ?', "%#{params[:slug]}%") if params[:slug].present?
    query = query.where(main_category: params[:main_category].to_s == 'yes') if params[:main_category].present?

    query
  end

  def site_id_and_name
    if Site.current
      name
    else
      "#{site_id} - #{name}"
    end
  end

  def update_active_coupons_count
    update_column(:active_coupons_count, coupons.active.count)
  end

  def is_active?
    status == 'active'
  end

  def is_pending?
    status == 'pending'
  end

  def is_blocked?
    status == 'blocked'
  end

  def is_gone?
    status == 'gone'
  end

  private

  def subcategory_is_not_main_category
    if parent_id.present? && main_category.present?
      errors.add(:parent_id, 'This Category cannot be subcategory and be marked as main category')
    end

    if main_category.blank? && sub_categories.any?
      errors.add(:main_category, 'This Category cannot be subcategory as it is already main category for category id: ' + sub_categories.map(&:id).to_sentence)
    end

    if parent_id.present? && sub_categories.any?
      errors.add(:parent_id, 'This Category cannot be subcategory as it is already main category for category id: ' + sub_categories.map(&:id).to_sentence)
    end
  end
end
