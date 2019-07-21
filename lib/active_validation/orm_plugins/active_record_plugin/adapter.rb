# frozen_string_literal: true

module ActiveValidation
  module OrmPlugins
    module ActiveRecordPlugin
      class Adapter < ActiveValidation::BaseAdapter
        loading_paths << "models"
        loading_paths << "types"
        loading_paths << "internals"

        def initialize
          setup unless self.class.initialised
        end

        # @return [true]
        def setup
          installator = lambda do
            ::ActiveRecord::Base.include ActiveValidation::ModelExtension
            ActiveValidation::OrmPlugins::ActiveRecordPlugin::Adapter.loader
            ActiveValidation::Internal::Models::Check.include(ActiveValidation::InternalModelExtensions::Check)
          end

          if defined?(::ActiveRecord::Base)
            installator.call
          else
            ::ActiveSupport.on_load(:active_record_adapter, &installator)
          end
          self.class.initialised = true
        end

        # @see BaseAdapter
        def add_manifest(manifest)
          Manifest.create manifest.as_json(checks: { only: %i[type argument options], as: :checks_attributes })
          manifest
        end

        # @see BaseAdapter
        def find_manifests(wheres)
          search(wheres).map(&ActiveValidation::Internal::Models::Manifest.method(:new))
        end

        # @see BaseAdapter
        def find_manifest(wheres)
          ActiveValidation::Internal::Models::Manifest.new search(wheres, &:first!)
        end

        private

        # @api internal
        def search(wheres)
          json_options = { include: { checks: { methods: %i[method_name] } }, root: false }
          relation = Manifest.includes(:checks).where(wheres).order(created_at: :desc)
          relation = yield relation if block_given?
          record_or_collection = relation.as_json(json_options)
          return record_or_collection.map(&:to_options!) if record_or_collection.is_a?(Array)

          record_or_collection.to_options!
        end
      end
    end
  end
end
