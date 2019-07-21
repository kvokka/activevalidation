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

    # @abstract
    # @param [Hash] Full description of the manifest
    # @option manifest_hash [String] :name Human readable name, by default build with selected
    #         formatter for current manifest
    # @option manifest_hash [String, Class] :base_klass (base_klass) Base klass for the Manifest
    # @option manifest_hash [String, Symbol, Integer, Values::Version] :version (:current) Version
    #         of the current manifest
    #
    # @example Add new manifest:
    #     add_manifest({  name: 'Cool Manifest',
    #        version: 42,
    #        base_klass: 'Bar',
    #        checks: [
    #     { type: "ValidatesMethod", argument: "some_column", options: { presence: true } }
    #     ]})
    #
    # @return [ActiveSupport::HashWithIndifferentAccess] if
    #         Verifier#@as_hash_with_indifferent_access == true
    # @return [OrmDependent] Return raw object orm the ORM, and depends on selected
    #         plugin. For example, it can be instance of class `ActiveRecord::Base`
    #         if Verifier#@as_hash_with_indifferent_access == false
    def add_manifest(**_manifest_hash)
      raise NotImplementedError, "abstract"
    end

    # @abstract
    # Return the most recent Manifest, which meet the criteria
    #
    # @param [Hash] Look up criteria
    # @option manifest_hash [String] :name Human readable name, by default build with selected
    #         formatter for current manifest
    # @option manifest_hash [String, Class] :base_klass (base_klass) Base klass for the Manifest
    # @option manifest_hash [String, Symbol, Integer, Values::Version] :version (:current) Version
    #         of the current manifest
    #
    # @example find_manifest({ base_klass: 'Bar' })
    #
    # @return [ActiveSupport::HashWithIndifferentAccess] if
    #         Verifier#@as_hash_with_indifferent_access == true
    # @return [OrmDependent] Return raw object orm the ORM, and depends on selected
    #         plugin. For example, it can be instance of class `ActiveRecord::Base`
    #         if Verifier#@as_hash_with_indifferent_access == false
    def find_manifest(**_wheres)
      raise NotImplementedError, "abstract"
    end

    # @abstract
    # Return the most recent Manifests, which meet the criteria
    #
    # @param [Hash] Look up criteria
    # @option manifest_hash [String] :name Human readable name, by default build with selected
    #         formatter for current manifest
    # @option manifest_hash [String, Class] :base_klass (base_klass) Base klass for the Manifest
    # @option manifest_hash [String, Symbol, Integer, Values::Version] :version (:current) Version
    #         of the current manifest
    #
    # @example find_manifests({ base_klass: 'Bar' })
    #
    # @return [ActiveSupport::HashWithIndifferentAccess] if
    #         Verifier#@as_hash_with_indifferent_access == true
    # @return [OrmDependent] Return raw object orm the ORM, and depends on selected
    #         plugin. For example, it can be instance of class `ActiveRecord::Base`
    #         if Verifier#@as_hash_with_indifferent_access == false
    def find_manifests(**_wheres)
      raise NotImplementedError, "abstract"
    end
  end
end
