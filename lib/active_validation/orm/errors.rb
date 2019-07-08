# frozen_string_literal: true

module ActiveValidation
  module Orm
    module Errors
      class NotSupported < StandardError
        def initialize(msg = "This object was designed as immutable.")
          super
        end
      end

      class NotImplemented
        def initialize(msg = "This method should be implemented in sub-class")
          super
        end
      end

      module Update
        def update
          raise NotSupported
        end
        alias update_attribute update
        alias update_attributes update
      end
    end
  end
end
