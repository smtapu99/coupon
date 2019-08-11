class Vote < ActiveRecord::Base
  belongs_to :shop
  scope :find_by_keypunch_keys, ->(shop_id, sub_id_tracking) { where(keypunch: Digest::SHA1.hexdigest("#{shop_id}-#{sub_id_tracking}")) }
end
