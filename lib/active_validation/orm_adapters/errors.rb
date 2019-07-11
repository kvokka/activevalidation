# frozen_string_literal: true

module ActiveValidation
  module OrmAdapters
    module Errors
      class ImmutableError < StandardError
        def initialize(msg = "Object can not be changed in lifetime")
          super
        end
      end
    end
  end
end
