# frozen_string_literal: true

module ActiveValidation
  class Configuration
    attr_accessor :foo

    def initialize
      @foo = "bar"
    end
  end
end
