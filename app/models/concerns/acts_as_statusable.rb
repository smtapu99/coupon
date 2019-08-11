module ActsAsStatusable
  extend ActiveSupport::Concern

  included do
    validate :valid_status

    private

    def valid_status
      self.errors.add(:status, "can only be #{self.class.statuses.values.to_sentence} ") unless self.class.statuses.keys.include?(status.to_sym)
    end
  end

  class_methods do
    attr_reader :statuses

    def has_statuses(statuses = {})
      @statuses = statuses
      setup_status_methods
    end

    def setup_status_methods
      @statuses.keys.each do |status|
        define_method("is_#{status}?") { self.status.to_sym == status.to_sym }
      end
    end
  end
end
