# frozen_string_literal: true

module ActiveValidation
  class Check < ActiveRecord::Base
    class ValidatesMethod < Check
      include Concerns::MethodMustBeAllowed
    end
  end
end
