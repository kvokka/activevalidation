# frozen_string_literal: true

module ActiveValidation
  class Check < ActiveRecord::Base
    class ValidateMethod < Check
      include Concerns::MethodMustBeAllowed

      class << self
        def argument_description
          "Should contain the name of the validation method"
        end
      end
    end
  end
end
