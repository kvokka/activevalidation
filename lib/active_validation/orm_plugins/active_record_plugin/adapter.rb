# frozen_string_literal: true

module ActiveValidation
  module OrmPlugins
    module ActiveRecordPlugin
      class Adapter < ActiveValidation::BaseAdapter
        loading_path << "models"

        def initialize
          setup unless self.class.initialised
        end

        # @return [void]
        def setup
          installator = lambda do
            ::ActiveRecord::Base.include ActiveValidation::ModelExtension
            # require_relative "models/active_validation/concerns/protect_from_mutable_instance_methods"
            # require_relative "models/active_validation/check"
            # require_relative "models/active_validation/check/concerns/method_must_be_allowed"
            # require_relative "models/active_validation/check/validate_method"
            # require_relative "models/active_validation/check/validates_method"
            # require_relative "models/active_validation/check/validate_with_method"
            # require_relative "models/active_validation/manifest"
            ActiveValidation::OrmPlugins::ActiveRecordPlugin::Adapter.loader
          end

          if defined?(::ActiveRecord::Base)
            installator.call
          else
            ::ActiveSupport.on_load(:active_record_adapter, &installator)
          end
          self.class.initialised = true
        end
      end
    end
  end
end
