# frozen_string_literal: true

module ActiveValidation
  class Engine < ::Rails::Engine
    # we have to use this path here
    orm = ActiveValidation::Configuration.instance.orm

    paths["app/models"] << "lib/active_validation/frameworks/#{orm}/models"
  end
end
