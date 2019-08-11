ActiveEnum.setup do |config|
  # Extend classes to add enumerate method
  config.extend_classes = [ ApplicationRecord ]

  # Return name string as value for attribute method
  config.use_name_as_value = true
end