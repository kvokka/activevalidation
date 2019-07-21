# frozen_string_literal: true

module ActiveValidation
  module Values
    class MethodName < Base
      # @param value [#to_i, #to_s]
      def initialize(value)
        unless allowed_methods.include? value.to_s
          raise ActiveValidation::Errors::UnsupportedMethodError.new value: value, allowed_methods: allowed_methods
        end

        super value.to_s
      end

      private

      def allowed_methods
        %w[validates validates_with validate].freeze
      end
    end
  end
end
