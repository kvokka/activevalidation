# frozen_string_literal: true

require "rails"
require "active_support/core_ext/numeric/time"
require "active_support/dependencies"
require "active_validation/configuration"
require "active_validation/adapters"
require "active_validation/railtie"

module ActiveValidation
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end
end
