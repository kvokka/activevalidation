# frozen_string_literal: true

module ActiveValidation
  module Orm
    module UpdateErrors
      class NotSupported < StandardError
        def initialize(msg = "This object was designed as immutable.")
          super
        end
      end

      def update
        raise NotSupported
      end
      alias update_attribute update
      alias update_attributes update
    end
  end
end
