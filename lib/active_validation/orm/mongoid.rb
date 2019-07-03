# frozen_string_literal: true

ActiveSupport.on_load(:mongoid) do
  require "active_validation/adapters/mongoid"

  ActiveValidation.configuration.orm ||= :mongoid

  Mongoid::Document.include ActiveValidation::ModelExtension
end
