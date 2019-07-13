# frozen_string_literal: true

module ActiveValidation
  module OrmPlugins
    module ActiveRecordPlugin
      class Adapter < ActiveValidation::BaseAdapter
        loading_paths << "models"
        loading_paths << "types"

        # Name of the folder, where all validations method should be scoped.
        # Inside, in corresponding sub-folder with version name shall be
        # stored validation related methods
        attr_accessor :validations_module_name

        def initialize
          setup unless self.class.initialised
          self.validations_module_name = "Validations"
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

        # @param [Verifier]
        # @return [Array<Symbol>] Sorted list of constants prefixed with 'V'
        def api_versions(verifier)
          verifier.base_klass.const_get(validations_module_name)
                  .constants.map { |k| ActiveValidation::Values::ApiVersion.new(k) }.sort
        rescue NameError
          []
        end

        def add_manifest(manifest_hash)
          Manifest.create! manifest_hash
        end
      end
    end
  end
end
