# frozen_string_literal: true

require "set"
require "active_support/core_ext/string/inflections"
require "active_support/core_ext/module/delegation"

module ActiveValidation
  autoload :Configuration,             "active_validation/configuration"
  autoload :ModelExtension,            "active_validation/model_extension"
  autoload :Orm,                       "active_validation/orm"

  require "active_validation/railtie" if defined? Rails

  class << self
    def configuration
      @configuration ||= Configuration.new
      yield(@configuration) if block_given?
      @configuration
    end
  end
end
