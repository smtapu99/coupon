# coding: utf-8
class Integer
  def to_b?
    !zero?
  end
end

# Array extensions
Array.class_eval do
  def except(*value)
    self - [*value]
  end

  def keys_with_highest_frequency
    freq = inject(Hash.new(0)) { |h,v| h[v] += 1; h }
    max = freq.values.max
    freq.select { |k, f| f == max }
  end
end

# String extensions
String.class_eval do
  def rtrim(char)
    self.rtrim!(char)
  end

  def rtrim!(char)
    gsub!(/#{Regexp.escape(char)}+$/, '')
  end

  def ltrim(char)
    self.ltrim!(char)
  end

  def ltrim!(char)
    gsub!(/^#{Regexp.escape(char)}+/, '')
  end

  def ucfirst
    slice(0,1).capitalize + slice(1..-1)
  end

  def is_i?
    !!(self =~ /^[-+]?[0-9]+$/)
  end

  def is_number?
    true if Float(self) rescue false
  end

  def to_slug
    transliterate.downcase.gsub(/[^a-z0-9 ]/, ' ').strip.gsub(/[ ]+/, '-')
  end

  # differs from the 'to_slug' method in that it leaves in the dot '.' character and removes Windows' crust from paths (removes "C:\Temp\" from "C:\Temp\mieczyslaw.jpg")
  def sanitize_as_filename
    gsub(/^.*(\\|\/)/, '').transliterate.downcase.gsub(/[^a-z0-9\. ]/, ' ').strip.gsub(/[ ]+/, '-')
  end

  def transliterate
    # Unidecode gem is missing some hyphen transliterations
    gsub(/[-‐‒–—―⁃−­]/, '-').to_ascii
  end

  def underscore
    gsub(/::/, '/')
    .gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
    .gsub(/([a-z\d])([A-Z])/,'\1_\2')
    .tr('-', '_')
    .downcase
  end
end

# Time formatters
Time::DATE_FORMATS[:detailed] = '%Y-%m-%d %H:%M'
Time::DATE_FORMATS[:brief] = '%Y-%m-%d'

OpenStruct.class_eval do
  def marshal_dump_recursive(options = {})
    convert_to_marshal_dump_recursive self, options
  end

  private

  def convert_to_marshal_dump_recursive(obj, options)
    result = obj
    if result.is_a? OpenStruct
      result.marshal_dump.each do |key, val|
        result[key] = convert_to_marshal_dump_recursive(val, options) unless options[:exclude].try(:include?, key)
      end
      result = result.marshal_dump
    end
    result
  end
end

Hash.class_eval do
  # options:
  #   :exclude => [keys] - keys need to be symbols
  def to_ostruct_recursive(options = {})
    convert_to_ostruct_recursive(self, options)
  end

  private

  def convert_to_ostruct_recursive(obj, options)
    result = obj
    if result.is_a? Hash
      result.each  do |key, val|
        result[key] = convert_to_ostruct_recursive(val, options) unless options[:exclude].try(:include?, key)
      end
      result = OpenStruct.new result
    elsif result.is_a? Array
      result = result.map { |r| convert_to_ostruct_recursive(r, options) }
    end
    result
  end
end
