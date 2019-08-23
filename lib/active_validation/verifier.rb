# frozen_string_literal: true

module ActiveValidation
  class Verifier
    class << self
      # Shortcut for the global verifiers registry instance
      # @return [Registry]
      def registry
        ActiveValidation.config.verifiers_registry
      end

      delegate :find_or_build, to: :registry
    end
    delegate :config, to: :ActiveValidation

    # Name of the folder, where all validations method should be scoped.
    # Inside, in corresponding sub-folder with version name shall be
    # stored validation related methods
    attr_accessor :validations_module_name

    # @note The corresponding model class
    attr_reader :base_klass

    # @note Orm adapter for exactly this verifier instance
    attr_accessor :orm_adapter

    # @note Custom name formatter for Manifests
    attr_accessor :manifest_name_formatter

    # Stick manifest to specific version
    # @return [Internal::Manifest]
    attr_accessor :manifest

    def initialize(base_klass)
      config.verifier_defaults.call self
      @base_klass = base_klass.to_s
      @orm_adapter ||= config.orm_adapter
      @manifest_name_formatter ||= config.manifest_name_formatter
      @validations_module_name = "Validations"

      yield self if block_given?
      self.class.registry.register base_klass, self
    end

    # @return [Array<Value::Version>] Sorted list of versions.
    def versions
      base_class.const_get(validations_module_name)
                .constants.map { |k| ActiveValidation::Values::Version.new(k) }.sort
    rescue NameError
      []
    end

    # @!group Manual version lock
    def version
      @version ||= versions.last
    end

    def version=(other)
      @version = versions.detect { |a| a == ActiveValidation::Values::Version.new(other) } or
        raise ArgumentError, "Version #{other} not found"
    end

    # @!endgroup

    # @return [ActiveSupport::HashWithIndifferentAccess]
    def current_manifest
      manifest or find_manifest(version: version)
    end

    # @return [Class]
    def base_class
      base_klass.is_a?(Class) ? base_klass : base_klass.constantize
    end

    # Return the list af parents with active_validation
    # @return [Array]
    def descendants_with_active_validation
      [].tap do |descendants|
        k = base_class.superclass
        while k.respond_to?(:active_validation)
          descendants << k
          k = k.superclass
        end
      end
    end

    def install(instance_manifest: nil)
      instance_manifest ||= find_manifest
      instance_manifest.to_internal_manifest.install
    end

    # Forward the normalized request to ORM mapper
    #
    # param [Hash]
    # return [Internal::Manifest, Array<Internal::Manifest>]

    %i[add_manifest find_manifest find_manifests].each do |m|
      define_method(m) { |**hash| add_defaults_for_orm_adapter(hash) { |**h| orm_adapter.public_send m, h } }
    end

    private

    def add_defaults_for_orm_adapter(**hash)
      hash[:base_klass] ||= base_klass
      hash[:version]    ||= version if version
      block_given? ? yield(hash) : hash
    end
  end
end
