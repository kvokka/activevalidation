# frozen_string_literal: true

module ActiveValidation
  class BaseAdapter
    class << self
      mattr_accessor :initialised, default: false

      def inherited(base)
        base.singleton_class.attr_accessor :abstract
        base.abstract = false
        ActiveValidation.config.orm_adapters_registry.register base.plugin_name, base
        super
      end

      # Abstract adapter should not be used directly
      def abstract
        true
      end

      def plugin_name
        regex = /Plugin\z/
        klass_name = name.split("::").detect { |c| c =~ regex }
        return "base" unless klass_name

        klass_name.sub(regex, "").underscore
      end

      def to_s
        abstract ? "#{plugin_name} (abstract)" : plugin_name
      end
    end

    delegate :to_s, to: :class

    # @abstract
    # should setup self.class.initialised to true after loading all dependencies
    def setup
      raise NotImplementedError, "abstract"
    end
  end
end
