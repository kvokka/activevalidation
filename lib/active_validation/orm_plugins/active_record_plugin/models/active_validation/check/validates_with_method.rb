# frozen_string_literal: true

module ActiveValidation
  class Check < ActiveRecord::Base
    class ValidatesWithMethod < Check
      validate :validator_must_be_defined

      private

      def validator_must_be_defined
        return if argument.blank?

        argument.constantize.is_a? ActiveModel::Validator
      rescue NameError
        errors.add :argument, "Validator not exist"
      end
    end
  end
end
