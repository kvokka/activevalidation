# frozen_string_literal: true

module ActiveValidation
  module Decorators
    class ConsistentRegistry < Decorator
      # All items in the registry must be ancestors of this Class
      # @return [Class]
      attr_reader :klass

      def initialize(klass, registry)
        super registry

        @klass = klass.is_a?(Class) ? klass : klass.to_s.constantize
      end

      def find_or_build(name, &block)
        return klass.new(name, &block) unless registered?(name)

        found = find(name)
        found.instance_exec(found, &block) if block
        found
      end

      def register(name, item)
        raise Errors::InconsistentRegistryError unless item.is_a? klass

        super
      end
    end
  end
end
