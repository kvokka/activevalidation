# frozen_string_literal: true

module ActiveValidation
  module Type
    class Version < ActiveModel::Type::Integer
      def serialize(value)
        value.to_i
      end

      def deserialize(value)
        return unless value

        ActiveValidation::Values::Version.new value
      end
    end
  end
end
