# frozen_string_literal: true

module ActiveValidation
  module Formatters
    module ManifestNameFormatter
      module_function

      def call(base_klass)
        "Manifest for #{base_klass}"
      end
    end
  end
end
