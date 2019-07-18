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

    # if true, return ActiveSupport::HashWithIndifferentAccess
    # if false will return the object, as it represented in ORM
    attr_accessor :as_hash_with_indifferent_access

    def initialize(base_klass)
      ActiveValidation.config.verifier_defaults.call self
      @base_klass = base_klass
      @orm_adapter ||= ActiveValidation.config.orm_adapter
      @manifest_name_formatter ||= ActiveValidation.config.manifest_name_formatter
      @as_hash_with_indifferent_access = true

      yield self if block_given?
      self.class.registry.register base_klass, self
    end

    delegate_missing_to :proxy

    # @!group Manual version lock
    def version
      @version ||= versions.last
    end

    def version=(other)
      other_value = ActiveValidation::Values::Version.new(other)
      versions.include?(other_value) or raise ArgumentError, "Version #{other} not found"
      @version = other_value
    end

    # @!endgroup

    # @!group Manual manifest management

    # @param [ActiveSupport::HashWithIndifferentAccess, #with_indifferent_access]
    # @return [ActiveSupport::HashWithIndifferentAccess]
    def manifest=(manifest)
      @manifest = manifest.with_indifferent_access
    end

    # @return [ActiveSupport::HashWithIndifferentAccess]
    attr_reader :manifest

    # @!endgroup

    # @return [ActiveSupport::HashWithIndifferentAccess]
    def current_manifest
      return manifest if manifest

      find_manifest(version: version).with_indifferent_access
    end

    # @return [Class]
    def base_class
      base_klass.is_a?(Class) ? base_klass : base_klass.constantize
    end

    private

    def proxy
      @proxy ||= VerifierProxy.new(self)
    end
  end
end
