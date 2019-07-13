# frozen_string_literal: true

module ActiveValidation
  class Verifier
    class << self
      # @param [Class] Class of the corresponding model
      # @yieldparam [Verifier] optional Invokes the block with self as argument
      # @return [Verifier]
      def find_or_build(base_klass, &block)
        return new(base_klass, &block) unless registry.registered?(base_klass)

        found = registry.find(base_klass)
        found.instance_exec(found, &block) if block_given?
        found
      end

      # Shortcut for the global verifiers registry instance
      # @return [Registry]
      def registry
        ActiveValidation.config.verifiers_registry
      end
    end

    # @note The corresponding model class
    attr_reader :base_klass

    # @note Orm adapter for exactly this verifier instance
    attr_accessor :orm_adapter

    # @note Custom name formatter for Manifests
    attr_accessor :manifest_name_formatter

    def initialize(base_klass)
      ActiveValidation.config.verifier_defaults.call self
      @base_klass = base_klass
      @orm_adapter ||= ActiveValidation.config.orm_adapter
      @manifest_name_formatter ||= ActiveValidation.config.manifest_name_formatter

      yield self if block_given?
      self.class.registry.register base_klass, self
    end

    # @note Version manual lock
    def version
      @version ||= versions.last
    end

    def version=(other)
      other_value = ActiveValidation::Values::Version.new(other)
      versions.include?(other_value) or raise ArgumentError, "Version #{other} not found"
      @version = other_value
    end

    def versions
      orm_adapter.versions self
    end

    def add_manifest(**manifest_hash)
      h = ActiveSupport::HashWithIndifferentAccess.new manifest_hash
      h[:name]        ||= manifest_name_formatter.call(base_klass)
      h[:version]     ||= version
      h[:base_klass]  ||= base_klass

      orm_adapter.add_manifest(h)
    end

    def find_manifest(**wheres)
      h = ActiveSupport::HashWithIndifferentAccess.new wheres
      h[:version] ||= version

      # TODO: maybe we should not allow to change base_klass here?
      h[:base_klass] ||= base_klass

      orm_adapter.find_manifest h
    end
  end
end
