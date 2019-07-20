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
      @version = versions.detect { |a| a == ActiveValidation::Values::Version.new(other) } or
        raise ArgumentError, "Version #{other} not found"
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

    # set validations on the current validator.
    #
    # @param [HashWithIndifferentAccess] :manifest, by default will be
    #     calculated current_manifest
    #
    # @return [void]
    def setup_validations(manifest = nil)
      manifest ||= current_manifest

      manifest.fetch(:checks).each do |check|
        method_name = check[:method_name].to_sym
        argument = method_name == :validates_with ? check[:argument].constantize : check[:argument].to_sym
        options = check[:options] || {}
        base_class.send(method_name, argument, options)
      end
    end

    # def install
    #   descendants_with_active_validation.reverse_each(&:set_validations)
    # end

    private

    def proxy
      @proxy ||= VerifierProxy.new(self)
    end
  end
end
