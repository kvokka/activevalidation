# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
ACTIVE_VALIDATION_ORM = (ENV["ACTIVE_VALIDATION_ORM"] || :active_record).to_sym

$LOAD_PATH.unshift File.dirname(__FILE__)
puts "\n==> ACTIVE_VALIDATION_ORM = #{ACTIVE_VALIDATION_ORM.inspect}"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_results"
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.disable_monkey_patching!
  config.warnings = false
  config.default_formatter = "doc" if config.files_to_run.one?
  config.order = :random
  Kernel.srand config.seed
end

require "rails_app/config/environment"
require "rspec/rails"

require "pry" if Gem::Specification.detect { |s| s.name == "pry" }

I18n.load_path << File.expand_path("support/locale/en.yml", __dir__)

Dir["#{File.dirname(__FILE__)}/support/*.rb"].each { |f| require f }

# load ORM related support modules
Dir["#{File.dirname(__FILE__)}/support/#{ACTIVE_VALIDATION_ORM}/*.rb"].each { |f| require f }

# Setup ORM for testing
require "orm/#{ACTIVE_VALIDATION_ORM}"

# Load model for selected ORM
require "active_validation/frameworks/#{ACTIVE_VALIDATION_ORM}"

# Define Orm agnostic models constants shortcuts

Check    = ActiveValidation::Check
Manifest = ActiveValidation::Manifest
