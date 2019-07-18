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
  end
end
