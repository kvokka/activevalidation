# frozen_string_literal: true

require_relative "boot"

require "rails/railtie"
require "rails/test_unit/railtie"

Bundler.require :default, ACTIVE_VALIDATION_ORM

# rubocop:disable Lint/HandleExceptions
begin
  require ACTIVE_VALIDATION_ORM.to_s if ACTIVE_VALIDATION_ORM == :mongoid
  require "#{ACTIVE_VALIDATION_ORM}/railtie" unless ACTIVE_VALIDATION_ORM == :mongoid &&
                                                    Mongoid::VERSION >= "5.0.0"
rescue LoadError
  # noop
end
# rubocop:enable Lint/HandleExceptions

require "active_validation"

module RailsApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.

    config.autoload_paths.reject! do |p|
      loading_app_folders = %w[] # example: ['helpers', 'views']
      p =~ %r{/app/(\w+)$} && !loading_app_folders.include?(Regexp.last_match(1))
    end
    config.autoload_paths += ["#{config.root}/app/#{ACTIVE_VALIDATION_ORM}"]

    rails_version = Gem::Version.new(Rails.version)
    if ACTIVE_VALIDATION_ORM == :active_record
      config.active_record.sqlite3.represent_boolean_as_integer = true

      if rails_version >= Gem::Version.new("4.2.0") && rails_version < Gem::Version.new("5.1.0")
        config.active_record.raise_in_transactional_callbacks = true
      end
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
