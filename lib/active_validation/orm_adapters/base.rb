# frozen_string_literal: true

module ActiveValidation
  module OrmAdapters
    class Base
      class << self
        def inherited(base)
          base.singleton_class.attr_accessor :abstract, :initialised
          base.abstract = false
          base.initialised = false
          ActiveValidation.config.orm_adapters_registry.register base.adapter_name, base
          super
        end

        # Abstract class should not be used directly
        def abstract
          true
        end

        def adapter_name
          name.demodulize.underscore
        end

        def to_s
          [adapter_name, abstract && "(abstract)"].join " "
        end
      end

      # @abstract
      # should setup self.class.initialised to true after loading all dependencies
      def setup
        raise NotImplementedError, "abstract"
      end
    end
  end
end
