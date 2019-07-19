# frozen_string_literal: true

module ActiveValidation
  class Configuration
    attr_reader :verifiers_registry, :orm_adapters_registry

    def initialize
      @verifiers_registry    = Decorators::ConsistentRegistry.new Verifier,
                                                                  Decorators::DisallowsDuplicatesRegistry.new(
                                                                    Registry.new("Verifiers")
                                                                  )
      @orm_adapters_registry = Registry.new("Orm adapters")
      @manifest_name_formatter = Formatters::ManifestNameFormatter
    end

    attr_accessor :manifest_name_formatter

    attr_reader :orm_adapter

    def orm_adapter=(name, retry_attempt: 0)
      retry_attempt += 1
      @orm_adapter = case name
                     when BaseAdapter
                       name
                     when Class
                       name.new
                     when String, Symbol
                       "ActiveValidation::OrmPlugins::#{name.to_s.classify}Plugin::Adapter".constantize.new
                     else
                       raise ArgumentError "ORM plugin not found"
                     end
    rescue NameError
      raise if retry_attempt > 1

      require_relative "orm_plugins/#{name}_plugin/adapter"
      retry
    end

    def verifier_defaults(&block)
      @verifier_defaults ||= ->(_config) {}
      return @verifier_defaults unless block_given?

      @verifier_defaults = block
    end
  end
end
