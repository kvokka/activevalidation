# frozen_string_literal: true

module ActiveValidation
  module Concerns
    module ProtectFromMutableInstanceMethods
      MUTABLE_INSTANCE_METHODS = %i[
        touch
        update
        update!
        update_all
        update_attribute
        update_attributes
        update_column
        update_columns
      ].freeze

      RESTRICTED_INSTANCE_METHODS = (MUTABLE_INSTANCE_METHODS + %i[delete destroy destroy_all]).freeze

      def restricted_instance_methods
        RESTRICTED_INSTANCE_METHODS
      end

      # By design all records must be immutable. I do not recommend to avoid
      # this restriction

      MUTABLE_INSTANCE_METHODS.each do |name|
        define_method(name) { |*| raise Errors::ImmutableError }
      end
    end
  end
end
