# frozen_string_literal: true

require "set"
require "active_support/core_ext/string/inflections"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/hash/indifferent_access"
require "active_support/ordered_options"
require "active_support/concern"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.ignore "#{__dir__}/active_validation/orm_plugins"
loader.setup

module ActiveValidation
  class << self
    def configuration
      @configuration ||= Configuration.new
      yield(@configuration) if block_given?
      @configuration
    end
    alias config configuration
  end
end
