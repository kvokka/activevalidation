# frozen_string_literal: true

module ActiveValidation
  module Internal
    module Models
      class Check
        attr_reader :method_name, :argument, :options, :created_at
        def initialize(method_name:, argument:, options: {}, created_at: nil, **_other)
          @method_name = registry.find_or_add method_name
          @argument = argument
          @options = options.to_h.to_options!
          @created_at = created_at
        end

        def ==(other)
          method_name == other.method_name &&
            argument    == other.argument &&
            options     == other.options
        end

        def to_hash
          as_json
        end

        def as_json(only: %i[method_name argument options], **_options)
          only.each_with_object({}) { |el, acc| acc[el.to_sym] = public_send(el).as_json }
        end

        def to_internal_check
          self
        end

        def normalized_argument
          method_name.to_sym == :validates_with ? argument.to_s.constantize : argument.to_sym
        end

        def to_validation_arguments(context: nil)
          [method_name.to_sym,
           normalized_argument,
           options.merge(on: context) { |_, old, new| Array(new) + Array(old) }]
        end

        private

        def registry
          ActiveValidation.config.method_name_values_registry
        end
      end
    end
  end
end
