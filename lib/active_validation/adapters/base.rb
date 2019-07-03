# frozen_string_literal: true

module ActiveValidation
  module Adapters
    class NotSupportedError < NotImplementedError
      def to_s
        "method not supported by this ORM adapter"
      end
    end

    class Base
      def self.inherited(adapter)
        Adapters.all << adapter
        super
      end

      def must_be_here()
        #TODO remove it after
        raise NotSupportedError
      end
    end
  end
end
