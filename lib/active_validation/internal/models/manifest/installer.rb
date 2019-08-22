# frozen_string_literal: true

using ActiveValidation::Internal::Models::Concerns::ToInternal::Check

module ActiveValidation
  module Internal
    module Models
      class Manifest
        class Installer
          attr_reader :base_class, :installed_callbacks, :checks, :context

          def initialize(base_class:, checks: [], context:)
            @base_class = base_class
            @checks = checks
            @context = context
          end

          # Add all checks (validations) to base_class
          #
          # @note we have to use the hack with
          # `callbacks_chain.each.to_a # => chain` since `chain` method is
          # protected.
          #
          # @return [TrueClass]
          def install
            @installed_callbacks = chain_mutex.synchronize do
              before = callbacks_chain_elements
              checks.each { |check| base_class.public_send(*check.to_validation_arguments(context: context)) }
              callbacks_chain_elements - before
            end
            true
          end

          # Remove all checks (validations) from base_class
          #
          # we can not use ActiveSupport provided methods, since we already have
          # our installed callbacks.
          #
          # @return [FalseClass]
          def uninstall
            installed_validators = installed_callbacks.map(&:filter).select { |f| f.is_a? ActiveModel::Validator }

            ([base_class] + ActiveSupport::DescendantsTracker.descendants(base_class)).reverse_each do |target|
              uninstall! target: target, installed_validators: installed_validators
            end
            installed_callbacks.clear
            false
          end

          def callbacks_chain
            base_class._validate_callbacks
          end

          private

          # We cannot call `chain` method directly, so we have to use this hack
          #
          # @return [Array<ActiveSupport::Callbacks>]
          def callbacks_chain_elements
            callbacks_chain.each.to_a
          end

          # Mutex from ActiveSupport::Callbacks::CallbackChain for `base_class`
          #
          # @return [Mutex]
          def chain_mutex
            callbacks_chain.instance_variable_get(:@mutex)
          end

          def uninstall!(target:, installed_validators:)
            chain = target._validate_callbacks

            chain.instance_variable_get(:@mutex).synchronize do
              target._validators
                    .each_value { |v| v.filter! { |el| !installed_validators.include?(el) } }
                    .delete_if { |_, v| v.empty?  }

              installed_callbacks.each { |callback| chain.delete(callback) }
            end
          end

          # def validators
          #   base_class._validators
          # end
          #
          # def uninstall_installed_validators
          #   installed_validators = installed_callbacks.map(&:filter).select { |f| f.is_a? ActiveModel::Validator }
          #   validators
          #     .each_value { |v| v.filter! { |el| !installed_validators.include?(el) } }
          #     .delete_if { |_, v| v.empty?  }
          # end
        end
      end
    end
  end
end
