# frozen_string_literal: true

module ActiveValidation
  class Configuration
    attr_reader :verifiers_registry, :orm_adapters_registry

    def initialize
      @verifiers_registry    = Registry.new("Verifiers")
      @orm_adapters_registry = Registry.new("Orm adapters")
    end

    def orm
      return @orm if @orm

      @orm = "active_record" if defined? ::ActiveRecord
      @orm = "mongoid"       if defined? ::Mongoid
      @orm
    end

    def orm=(other)
      @orm = Orm::Finder.call(other)
    end

    def verifier_defaults(&block)
      @model_extension_defaults ||= ->(*) {}
      return @model_extension_defaults unless block_given?

      @model_extension_defaults = block
    end
  end
end
