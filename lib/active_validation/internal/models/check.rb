# frozen_string_literal: true

module ActiveValidation
  module Internal
    module Models
      class Check
        attr_reader :method_name, :argument, :options, :created_at
        def initialize(method_name:, argument:, options: {}, created_at: nil, **_other)
          @method_name = registry.find_or_add method_name
          @argument = argument
          @options = options
          @created_at = created_at
        end

        def ==(other)
          method_name == other.method_name &&
            argument    == other.argument &&
            options     == other.options
        end

        def to_hash
          { method_name: method_name, argument: argument, options: options }
        end

        private

        def registry
          ActiveValidation.config.method_name_values_registry
        end
      end
    end
  end
end
