# class Template
#   include ActiveModel::Validations
#   include ActiveModel::Conversion
#   extend ActiveModel::Naming

#   liquid_methods :main_search_frame

#   class << self
#     def all
#       return []
#     end
#   end

#   def initialize(attributes = {})
#     attributes.each do |name, value|
#       send("#{name}=", value)
#     end
#   end

#   def persisted?
#     false
#   end

#   def main_search_frame
#     'ABCDEF'
#   end
# end