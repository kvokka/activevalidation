# frozen_string_literal: true

module ActiveValidation
  module Values
    class ApiVersion < Base
      # @param value [#to_i, #to_s]
      def initialize(value)
        return super if Base::BAD_VALUES.include? value
        return super value.to_i if value.respond_to? :to_int
        super Integer(value.to_s.sub(/\AV/, ""))
      end

      def to_i
        value
      end
    end
  end
end
