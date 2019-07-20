# frozen_string_literal: true

module ActiveValidation
  module Internal
    module Models
      class Manifest
        attr_reader :version, :base_klass, :created_at, :checks, :options, :other

        def initialize(version:, base_klass:, checks: [], options: {}, **other)
          @version = ActiveValidation::Values::Version.new version
          @base_klass = base_klass.to_s
          @checks = Array(checks)
          @other = ActiveSupport::OrderedOptions.new other

          @options = Hash(options)
        end

        delegate :id, :name, :created_at, to: :other

        def ==(other)
          return true if id == other.id

          version == other.version &&
            base_klass == other.base_klass &&
            options     == other.options &&
            checks      == other.checks
        end

        def base_class
          base_klass.constantize
        end

        def to_hash
          { version: version, base_klass: base_klass, checks: checks, name: name, id: id }
        end

        private

        def registry
          # ActiveValidation.config.method_name_values_registry
        end
      end
    end
  end
end
