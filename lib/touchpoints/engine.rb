module Touchpoints
  class Engine < ::Rails::Engine
    # We want all the helpers to be used in the app
    #isolate_namespace Touchpoints

    config.app_generators do |g|
      g.stylesheets false
      g.javascripts false
    end
  end
end
