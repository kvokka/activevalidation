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

    # @note Api version manual lock
    def api_version
      @api_version ||= api_versions.last
    end

    def api_version=(other)
      other_value = ActiveValidation::Values::ApiVersion.new(other)
      api_versions.include?(other_value) or raise ArgumentError, "Api version #{other} not found"
      @api_version = other_value
    end

    def api_versions
      orm_adapter.api_versions self
    end

    def add_manifest(**manifest_hash)
      h = ActiveSupport::HashWithIndifferentAccess.new manifest_hash
      h[:name]        ||= manifest_name_formatter.call(base_klass)
      h[:version]     ||= api_version
      h[:base_klass]  ||= base_klass

      orm_adapter.add_manifest(h)
    end

    def find_manifest(version: :current, **wheres)
      h = ActiveSupport::HashWithIndifferentAccess.new wheres

      # TODO: maybe rename :version to api_version or dsl_version?
      h[:version] = api_version if version == :current

      # TODO: maybe we should not allow to change base_klass here?
      h[:base_klass] ||= base_klass

      orm_adapter.find_manifest h
    end
  end
end
