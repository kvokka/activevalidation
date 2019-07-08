# frozen_string_literal: true

module ActiveValidation
  class Check < ActiveRecord::Base
    class ValidateMethod < Check
      validate :method_must_be_allowed

      class << self
        def argument_description
          "Should contain the name of the validation method"
        end

        # list of restricted methods in the checking instance
        def validation_restricted_methods
          %i[delete destroy update update_attribute]
        end
      end

      private

      def method_must_be_allowed
        if !argument || !manifest.try(:model_klass)
          nil
        elsif self.class.validation_restricted_methods.include?(argument.to_sym)
          errors.add :argument, "method #{argument} is globally restricted for usage in validation"
        elsif Array(manifest.model_class.try(:validation_restricted_methods)).map(&:to_sym).include?(argument.to_sym)
          errors.add :argument, "method #{argument} is restricted for usage in validation"
        end
      end
    end
  end
end
