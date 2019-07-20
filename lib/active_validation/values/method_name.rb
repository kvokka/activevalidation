# frozen_string_literal: true

module ActiveValidation
  module Values
    class MethodName < Base
      # @param value [#to_i, #to_s]
      def initialize(value)
        unless allowed_methods.include? value.to_sym
          raise ActiveValidation::Errors::UnsupportedMethodError.new value: value, allowed_methods: allowed_methods
        end

        super
      end

      private

      def allowed_methods
        %i[validates validates_with validate].freeze
      end
    end
  end
end
