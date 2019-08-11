module TruncateReferrer
  extend ActiveSupport::Concern

  included do
    before_validation :truncate_referrer

    def truncate_referrer
      if self.referrer.present? && self.referrer.is_a?(String) && self.referrer.length > 255
        self.referrer = self.referrer[0..254]
      end
    end
  end
end
