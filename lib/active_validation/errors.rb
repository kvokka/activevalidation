# frozen_string_literal: true

module ActiveValidation
  module Errors
    class ImmutableError < StandardError
      def initialize(msg = "Object can not be changed in lifetime")
        super
      end
    end

    class DuplicateRegistryEntryError < RuntimeError; end

    class InconsistentRegistryError < ArgumentError; end

    class UnsupportedMethodError < ArgumentError
      attr_reader :value, :allowed_methods
      def initialize(value:, allowed_methods:)
        super
        @value = value
        @allowed_methods = allowed_methods
      end

      def to_s
        "You provided #{value.inspect} while supported are only #{allowed_methods.inspect}"
      end
    end
  end
end
