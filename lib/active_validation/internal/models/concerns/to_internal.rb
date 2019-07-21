# frozen_string_literal: true

module ActiveValidation
  module Internal
    module Models
      module Concerns
        module ToInternal
          module Check
            refine Hash do
              def to_internal_check
                ActiveValidation::Internal::Models::Check.new to_options!
              end
            end
          end

          module Manifest
            refine Hash do
              def to_internal_manifest
                ActiveValidation::Internal::Models::Manifest.new to_options!
              end
            end
          end
        end
      end
    end
  end
end
