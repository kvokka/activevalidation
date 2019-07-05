# frozen_string_literal: true

require "singleton"

module ActiveValidation
  class Configuration
    include Singleton

    attr_reader :orm

    def initialize
      # Variables which affect all threads, whose access is synchronized.
      @mutex = Mutex.new
      self.orm = :active_record if defined? ActiveRecord
      self.orm = :mongoid       if defined? Mongoid
    end

    def orm=(other)
      @mutex.synchronize { @orm = Orm.find! other }
    end
  end
end
