# frozen_string_literal: true

require "singleton"

module ActiveValidation
  class Configuration
    include Singleton

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

    def verifiers_registry
      @verifiers_registry ||= Registry.new("Verifiers")
    end
  end
end
