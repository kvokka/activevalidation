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
  end
end
