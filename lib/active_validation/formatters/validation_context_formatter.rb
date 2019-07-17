# frozen_string_literal: true

module ActiveValidation
  module Formatters
    module ValidationContextFormatter
      module_function

      def call(manifest_id, on = nil)
        base = "manifest#{manifest_id}"
        on.blank? ? base : [base, on].join("_")
      end
    end
  end
end
