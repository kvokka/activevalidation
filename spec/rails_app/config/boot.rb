# frozen_string_literal: true

ACTIVE_VALIDATION_ORM = (ENV["ACTIVE_VALIDATION_ORM"] || :active_record).to_sym unless defined?(ACTIVE_VALIDATION_ORM)

module ActiveValidation
  module RailsApp
    # Detection for minor differences between Rails 4 and 5, 5.1, and 5.2 in tests.

    def self.rails52?
      Rails.version.start_with? "5.2"
    end

    def self.rails51?
      Rails.version.start_with? "5.1"
    end

    def self.rails5?
      Rails.version.start_with? "5"
    end
  end
end

# Set up gems listed in the Gemfile.
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../../Gemfile", __dir__)

require "bundler/setup" if File.exist?(ENV["BUNDLE_GEMFILE"])
$LOAD_PATH.unshift File.expand_path("../../../lib", __dir__)
