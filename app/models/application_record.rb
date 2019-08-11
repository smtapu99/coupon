class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.string_to_utc_time(name, date_string)
    if date_string.length == 10
      date_string += ' 00:00:00' if name.end_with?('_from')
      date_string += ' 23:59:59' if name.end_with?('_to')
    end

    date_string.to_time.utc
  end
end
