# frozen_string_literal: true

module ActiveValidation
  class BaseAdapter
    class << self
      mattr_accessor :initialised, default: false

      def inherited(base)
        base.singleton_class.attr_accessor :abstract

        # set default loading paths from the plugin root folder
        base.singleton_class.attr_accessor :loading_paths
        base.loading_paths = []
        base.abstract = false
        ActiveValidation.config.orm_adapters_registry.register base.plugin_name, base
        super
      end

      def loader
        return @loader if @loader

        @loader = Zeitwerk::Loader.new
        loading_paths.each do |loading_path|
          @loader.push_dir [__dir__, "orm_plugins", plugin_name, loading_path].join("/")
        end
        @loader.setup
        @loader
      end

      # Abstract adapter should not be used directly
      def abstract
        true
      end

      def plugin_name
        klass_name = name.split("::").detect { |c| c =~ /Plugin\z/ }
        klass_name ? klass_name.underscore : "base"
      end

      def adapter_name
        plugin_name.sub(/_plugin\z/, "")
      end

      def to_s
        abstract ? "#{plugin_name} (abstract)" : plugin_name
      end
    end

    delegate :to_s, :plugin_name, :adapter_name, to: :class

    # @abstract
    # should setup self.class.initialised to true after loading all dependencies
    def setup
      raise NotImplementedError, "abstract"
    end
  end
end
