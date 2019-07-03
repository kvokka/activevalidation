# frozen_string_literal: true

ActiveSupport.on_load(:active_record) do
  require "active_validation/adapters/active_record"

  ActiveValidation.configuration.orm ||= :active_record

  base = defined?(::ApplicationRecord) ? ::ApplicationRecord : ::ActiveRecord::Base
  base.include(ActiveValidation::ModelExtension)
end
