# frozen_string_literal: true

ACTIVE_VALIDATION_ORM = (ENV["ACTIVE_VALIDATION_ORM"] || :active_record).to_sym unless defined?(ACTIVE_VALIDATION_ORM)

# Set up gems listed in the Gemfile.
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../../Gemfile", __dir__)

require "bundler/setup" if File.exist?(ENV["BUNDLE_GEMFILE"])
$LOAD_PATH.unshift File.expand_path("../../../lib", __dir__)
