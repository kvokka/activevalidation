# frozen_string_literal: true

module ActiveValidation
  module Errors
    class ImmutableError < StandardError
      def initialize(msg = "Object can not be changed in lifetime")
        super
      end
    end

    class DuplicateRegistryEntryError < RuntimeError; end

    class NotFoundError < RuntimeError; end

    class InconsistentRegistryError < ArgumentError; end

    class MustRespondTo < RuntimeError
      attr_reader :method_name, :base
      def initialize(base:, method_name:)
        super
        @base = base
        @method_name = method_name
      end

      def to_s
        "The object #{base.inspect} with class #{base.class.inspect} must respond_to method ##{method_name}"
      end
    end

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
