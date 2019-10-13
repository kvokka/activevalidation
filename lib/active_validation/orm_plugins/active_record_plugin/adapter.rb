# frozen_string_literal: true

module ActiveValidation
  module OrmPlugins
    module ActiveRecordPlugin
      class Adapter < ActiveValidation::BaseAdapter
        loading_paths << "models"
        loading_paths << "types"
        loading_paths << "internals"
        loading_paths << "model_extension"

        def initialize
          setup unless self.class.initialised
          self.class.initialised = true
        end

        # @return [true]
        def setup
          return installer if defined?(::ActiveRecord::Base)

          ::ActiveSupport.on_load(:active_record_adapter, &method(:installer))
        end

        # @see BaseAdapter
        def add_manifest(manifest)
          Manifest.create manifest.as_json(checks: { only: %i[type argument options], as: :checks_attributes })
          manifest
        end

        # @see BaseAdapter
        def find_manifests(wheres)
          search(wheres)
        end

        # @see BaseAdapter
        def find_manifest(wheres)
          search(wheres, &:first!)
        end

        private

        # @api internal
        def search(wheres)
          relation = Manifest.includes(:checks).where(wheres).order(created_at: :desc, id: :desc)
          relation = yield relation if block_given?
          relation.is_a?(ActiveRecord::Base) ? relation.to_internal_manifest : relation.map(&:to_internal_manifest)
        end

        # @return [true]
        def installer
          ActiveValidation::OrmPlugins::ActiveRecordPlugin::Adapter.loader
          ActiveValidation::Internal::Models::Check.include(ActiveValidation::InternalModelExtensions::Check)
          ::ActiveRecord::Base.include ActiveValidation::ActiveRecordModelExtension
          true
        end
      end
    end
  end
end
