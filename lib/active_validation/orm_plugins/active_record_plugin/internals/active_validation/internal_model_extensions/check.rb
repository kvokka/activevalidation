# frozen_string_literal: true

module ActiveValidation
  module InternalModelExtensions
    module Check
      def type
        method_name.to_s.camelcase.concat "Method"
      end
    end
  end
end
