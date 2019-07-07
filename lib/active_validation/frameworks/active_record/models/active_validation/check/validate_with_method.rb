# frozen_string_literal: true

module ActiveValidation
  class Check < ActiveRecord::Base
    class ValidateWithMethod < Check
      class << self
        def argument_description
          "Should contain ActiveModel::Validator sub-class"
        end
    end
    end
  end
end
