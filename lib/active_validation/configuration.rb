# frozen_string_literal: true

module ActiveValidation
  class Configuration
    attr_reader :orm

    def initialize
      self.orm = :active_record if defined? ActiveRecord
      self.orm = :mongoid       if defined? Mongoid
    end

    def orm=(other)
      @orm = Orm.find! other
    end
  end
end
