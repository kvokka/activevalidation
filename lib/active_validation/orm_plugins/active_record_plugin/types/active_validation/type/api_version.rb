# frozen_string_literal: true

module ActiveValidation
  module Type
    class ApiVersion < ActiveModel::Type::Integer
      def serialize(value)
        value.to_i
      end

      def deserialize(value)
        return unless value

        ActiveValidation::Values::ApiVersion.new value
      end
    end
  end
end
