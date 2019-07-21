# frozen_string_literal: true

module ActiveValidation
  class Verifier
    class << self
      # @param [Class] Class of the corresponding model
      # @yieldparam [Verifier] optional Invokes the block with self as argument
      # @return [Verifier]
      delegate :find_or_build, to: :registry

      # Shortcut for the global verifiers registry instance
      # @return [Registry]
      def registry
        ActiveValidation.config.verifiers_registry
      end
    end

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

    # if true, return ActiveSupport::HashWithIndifferentAccess
    # if false will return the object, as it represented in ORM
    attr_accessor :as_hash_with_indifferent_access

    def initialize(base_klass)
      ActiveValidation.config.verifier_defaults.call self
      @base_klass = base_klass.to_s
      @orm_adapter ||= ActiveValidation.config.orm_adapter
      @manifest_name_formatter ||= ActiveValidation.config.manifest_name_formatter
      @as_hash_with_indifferent_access = true
      @validations_module_name = "Validations"

      yield self if block_given?
      self.class.registry.register base_klass, self
    end

    # delegate_missing_to :proxy

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

    # @return [Internal::Manifest]
    attr_accessor :manifest

    # @return [ActiveSupport::HashWithIndifferentAccess]
    def current_manifest
      manifest or find_manifest(version: version).with_indifferent_access
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

    # # set validations on the current validator.
    # #
    # # @param [HashWithIndifferentAccess] :manifest, by default will be
    # #     calculated current_manifest
    # #
    # # @return [void]
    # def setup_validations(manifest = nil)
    #   manifest ||= current_manifest
    #
    #   manifest.fetch(:checks).each do |check|
    #     method_name = check[:method_name].to_sym
    #     argument = method_name == :validates_with ? check[:argument].constantize : check[:argument].to_sym
    #     options = check[:options] || {}
    #     base_class.send(method_name, argument, options)
    #   end
    # end

    # Forward the normalized request to ORM mapper
    #
    # param [Hash]
    # return [Internal::Manifest, Array<Internal::Manifest>]

    %i[add_manifest find_manifest find_manifests].each do |m|
      define_method(m) { |**hash| add_defaults_for_orm_adapter(hash) { |**h| orm_adapter.send m, h } }
    end

    private

    # def proxy
    #   @proxy ||= VerifierProxy.new(self)
    # end

    def add_defaults_for_orm_adapter(**hash)
      hash[:base_klass] ||= base_klass
      hash[:version]    ||= version if version
      block_given? ? yield(hash) : hash
    end
  end
end
