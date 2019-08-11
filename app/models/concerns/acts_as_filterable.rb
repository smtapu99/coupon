module ActsAsFilterable
  extend ActiveSupport::Concern

  module ClassMethods
    def with_filter(filter_params={})
      results = self.where(nil)
      filter_params.each do |key, value|
        results = if value.present?
          results.public_send(key, value)
        else
          results.public_send(key)
        end
      end
      results
    end
  end
end
