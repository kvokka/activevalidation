# frozen_string_literal: true

module ActiveValidation
  module Values
    class Base
      BAD_VALUES = [nil, true, false]

      attr_reader :value

      def initialize(value)
        raise ArgumentError, "Value of #{self.class} can not be #{value.inspect}" if BAD_VALUES.include? value
        @value = value.freeze
      end

      def <=>(other)
        raise ArgumentError, "Inconcictent classes #{self.class} and #{other.class}" unless self.class == other.class

        value <=> other.value
      end

      def ==(other)
        value == other
      end

      def to_s
        value.to_s
      end
    end
  end
end