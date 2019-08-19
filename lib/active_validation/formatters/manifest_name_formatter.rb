# frozen_string_literal: true

module ActiveValidation
  module Formatters
    class ManifestNameFormatter
      class << self
        def call(base_klass)
          "Manifest for #{base_klass}"
        end
      end
    end
  end
end
