# frozen_string_literal: true

using ActiveValidation::Internal::Models::Concerns::ToInternal::Check

module ActiveValidation
  module Internal
    module Models
      class Manifest
        attr_reader :version, :base_klass, :created_at, :checks, :options, :other, :id, :name, :installed_callbacks

        # @param [Hash] Manifest options hash
        # @option manifest_hash [String] :name Human readable name, by default build with selected
        #         formatter for current manifest
        # @option manifest_hash [String, #to_s] :base_klass (base_klass) Base klass for the Manifest
        # @option manifest_hash [String, Symbol, Integer, Values::Version] :version (:current) Version
        #         of the current manifest
        # @option manifest_hash [Internal::Check] :checks ([])
        #
        # @example Add new manifest:
        #     new({  name: 'Cool Manifest',
        #        version: 42,
        #        base_klass: 'Bar',
        #        checks: [
        #           { method_name: "validates", argument: "name", options: { presence: true } }
        #        ]})
        def initialize(version:, base_klass:, checks: [], options: {}, **other)
          @version = ActiveValidation::Values::Version.new version
          @base_klass = base_klass.to_s
          @checks = Array(checks).map(&:to_internal_check)
          @other = ActiveSupport::OrderedOptions.new other

          @id = other[:id]
          @name = other[:name]
          @created_at = other[:created_at]
          @options = options.to_h.to_options!
        end

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
          as_json
        end

        # Add all checks (validations) to base_class
        #
        # @note we have to use the hack with
        # `callbacks_chain.each.to_a # => chain` since `chain` method is
        # protected.
        #
        # @return [TrueClass]
        def install
          return true if installed?

          @installed_callbacks = chain_mutex.synchronize do
            before = callbacks_chain.each.to_a
            checks.each { |check| base_class.public_send(*check.to_validation_arguments(context: context)) }
            callbacks_chain.each.to_a - before
          end
          @installed = true
        end

        # Remove all checks (validations) from base_class
        #
        # @return [FalseClass]
        def uninstall
          return false unless installed?

          chain_mutex.synchronize do
            installed_validators = installed_callbacks.map(&:filter).select { |f| f.is_a? ActiveModel::Validator }
            validators
              .each_value { |v| v.filter! { |el| !installed_validators.include?(el) } }
              .delete_if { |_, v| v.empty?  }

            installed_callbacks.each { |callback| callbacks_chain.delete(callback) }.clear
          end
          @installed = false
        end

        # Are the callbacks installed to the `base_class`?
        #
        # @return [TrueClass, FalseClass]
        def installed?
          !!@installed
        end

        # ActiveSupport#as_json interface
        # Supported options:
        #   :only [Array<Symbol>, Symbol] select only listed elements
        #
        # Nested elements accept options:
        #   :only [Array<Symbol>, Symbol] select only listed elements
        #   :as   [Symbol, String] in place rename for the column
        #
        # @example
        #     as_json(only: :version, checks: { as: :checks_attributes,
        #                                       only: [:argument] })
        #
        # @return [Hash]
        def as_json(only: %i[version base_klass checks name id], **options)
          only = Array(only)
          {}.tap do |acc|
            options.each_pair do |k, v|
              only.delete(k)
              as = v.delete(:as)
              key_name = (as || k).to_sym
              acc[key_name] = public_send(k).as_json(v)
            end
            only.each { |el| acc[el.to_sym] = public_send(el).as_json }
          end
        end

        def to_internal_manifest
          self
        end

        # Formatted context, as it will be stored on `on` option with the
        # validations
        #
        # @return [String]
        def context
          @context ||= ActiveValidation.config.validation_context_formatter.call self
        end

        private

        # Mutex from ActiveSupport::Callbacks::CallbackChain for `base_class`
        #
        # @return [Mutex]
        def chain_mutex
          callbacks_chain.instance_variable_get(:@mutex)
        end

        def callbacks_chain
          base_class._validate_callbacks
        end

        def validators
          base_class._validators
        end
      end
    end
  end
end
