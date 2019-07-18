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
        # @return [Array<Value::Version>] Sorted list of versions.
        def versions(verifier)
          verifier.base_class.const_get(validations_module_name)
                  .constants.map { |k| ActiveValidation::Values::Version.new(k) }.sort
        rescue NameError
          []
        end

        # @see BaseAdapter
        def add_manifest(manifest_hash)
          h = ActiveSupport::HashWithIndifferentAccess.new manifest_hash
          h[:checks_attributes] ||= h.delete(:checks) || []
          h[:checks_attributes].each do |check|
            check[:type] ||= check.delete(:method_name)&.camelcase&.concat("Method")
          end

          Manifest.create!(h)
        end

        # @see BaseAdapter
        def find_manifests(wheres)
          Manifest.where(wheres).order(created_at: :desc)
        end

        # @see BaseAdapter
        def find_manifest(wheres)
          Manifest.where(wheres).order(created_at: :desc).first
        end
      end
    end
  end
end
