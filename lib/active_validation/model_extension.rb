# frozen_string_literal: true

module ActiveValidation
  module ModelExtension
    extend ActiveSupport::Concern
    # Here will be described shared ORM method

    module ClassMethods
      def active_validation
        ::ActiveValidation::Verifier.find_or_build self
      end
    end
  end
end
