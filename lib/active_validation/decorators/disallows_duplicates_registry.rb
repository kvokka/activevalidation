# frozen_string_literal: true

module ActiveValidation
  module Decorators
    class DisallowsDuplicatesRegistry < Decorator
      def register(name, item)
        return @component.register(name, item) unless registered?(name)

        raise Errors::DuplicateRegistryEntryError, "#{@component.name} already registered: #{name}"
      end

      def ==(other)
        object_id == other.object_id
      end
    end
  end
end
