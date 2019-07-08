# frozen_string_literal: true

require_relative "boot"

require "rails/railtie"
require "rails/test_unit/railtie"

Bundler.require :default, ACTIVE_VALIDATION_ORM

# rubocop:disable Lint/HandleExceptions
begin
  require ACTIVE_VALIDATION_ORM == :mongoid ? ACTIVE_VALIDATION_ORM.to_s : "#{ACTIVE_VALIDATION_ORM}/railtie"
rescue LoadError
  # noop
end
# rubocop:enable Lint/HandleExceptions

require "active_validation"

module RailsApp
  class Application < Rails::Application
    config.autoload_paths += ["#{config.root}/app/models/#{ACTIVE_VALIDATION_ORM}"]

    rails_version = Gem::Version.new(Rails.version)
    if ACTIVE_VALIDATION_ORM == :active_record
      config.active_record.sqlite3.represent_boolean_as_integer = true

      if rails_version >= Gem::Version.new("5.0.0") && rails_version < Gem::Version.new("5.1.0")
        config.active_record.raise_in_transactional_callbacks = true
      end
    end
  end
end
