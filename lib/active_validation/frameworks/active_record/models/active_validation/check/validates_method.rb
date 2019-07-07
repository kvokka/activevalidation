# frozen_string_literal: true

module ActiveValidation
  class Check < ActiveRecord::Base
    class ValidatesMethod < Check
      class << self
        def argument_description
          "Should contain column name"
        end
      end
    end
  end
end
