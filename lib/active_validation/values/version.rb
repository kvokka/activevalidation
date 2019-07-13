# frozen_string_literal: true

module ActiveValidation
  module Values
    class Version < Base
      # @param value [#to_i, #to_s]
      def initialize(value)
        super
        @value = value.respond_to?(:to_int) ? value.to_i : Integer(value.to_s.sub(/\AV/, ""))
      end

      def to_i
        value
      end
    end
  end
end
