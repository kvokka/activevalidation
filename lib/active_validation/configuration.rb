# frozen_string_literal: true

require "singleton"

module ActiveValidation
  class Configuration
    include Singleton

    def orm
      return @orm if @orm

      @orm = :active_record if defined? ::ActiveRecord
      @orm = :mongoid       if defined? ::Mongoid
      @orm
    end

    def orm=(other)
      @orm = Orm::Finder.call(other)
    end
  end
end
