# frozen_string_literal: true

require "set"
require "active_support/core_ext/string/inflections"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/hash/indifferent_access"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.push_dir "lib/active_validation/frameworks/active_record/models"
loader.setup

module ActiveValidation
  class << self
    def configuration
      @configuration ||= Configuration.instance
      yield(@configuration) if block_given?
      @configuration
    end
    alias config configuration
  end
end
