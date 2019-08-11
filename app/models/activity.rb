class Activity < ApplicationRecord
  def self.unique_trackables_by_user_ids_and_site user_ids, site_id
     query  = where(owner_id: user_ids, owner_type: "User")
     query  = query.where(site_id: site_id) unless site_id.nil?
     query  = query.order(trackable_type: :asc)
     query  = query.pluck(:trackable_type)
     query.uniq
  end
end