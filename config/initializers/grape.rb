module Grape
  class Endpoint
    include ApplicationHelper
    include Rails.application.routes.url_helpers
  end
end
