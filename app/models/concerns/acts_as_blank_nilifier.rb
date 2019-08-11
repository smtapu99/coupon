module ActsAsBlankNilifier
  extend ActiveSupport::Concern

  included do

    after_commit :nilify_blanks

    def nilify_blanks
      self.attributes.each do |column|
        value = read_attribute(column)
        next unless value.is_a?(String)
        next unless value.respond_to?(:blank?)

        write_attribute(column, nil) if value.blank?
      end
    end
  end
end
