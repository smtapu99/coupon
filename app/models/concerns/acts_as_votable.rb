module ActsAsVotable
  extend ActiveSupport::Concern
  include ActiveSupport::NumberHelper

  included do

    has_many :votes

    def add_vote(stars, sub_id_tracking)
      stars ||= 5
      if vote = self.votes.create(stars: stars, keypunch: Digest::SHA1.hexdigest("#{self.id}-#{sub_id_tracking}"))
        self.update_attributes(total_stars: (total_stars + stars.to_i), total_votes: (total_votes + 1))
      end
      vote
    end

    def rating
      total_stars.to_f / (total_votes.zero? ? 1 : total_votes).to_f
    end

    def formatted_rating
      I18n.global_scope = :backend
      number = number_to_delimited(rating.round(2))
      I18n.global_scope = :frontend
      number
    end
  end
end
