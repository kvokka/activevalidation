# frozen_string_literal: true

module ActiveValidation
  class Verifier
    attr_reader :base_klass, :orm_adapter

    def initialize(base_klass)
      ActiveValidation.config.verifier_defaults.call self
      yield self if block_given?

      ActiveValidation.config.verifiers_registry.register base_klass, self
      @orm_adapter ||= ActiveValidation.config.orm_adapter
      @base_klass = base_klass
    end
  end
end
