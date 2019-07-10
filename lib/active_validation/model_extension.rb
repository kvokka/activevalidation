# frozen_string_literal: true

module ActiveValidation
  module ModelExtension
    extend ActiveSupport::Concern
    # Here will be described shared ORM method

    module ClassMethods
      def active_validation
        ::ActiveValidation::Verifier.new self
      end
    end
  end
end
