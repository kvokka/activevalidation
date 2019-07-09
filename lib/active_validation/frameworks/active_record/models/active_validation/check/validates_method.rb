# frozen_string_literal: true

module ActiveValidation
  class Check < ActiveRecord::Base
    class ValidatesMethod < Check
      include MethodMustBeAllowed

      class << self
        def argument_description
          "Should contain column name"
        end
      end
    end
  end
end
