class CategoryTag < ApplicationRecord
  belongs_to :category
  belongs_to :tag
  has_one :site, through: :category

  validates_uniqueness_of :category_id, scope: :tag_id
  validates :category_id, presence: true
end
