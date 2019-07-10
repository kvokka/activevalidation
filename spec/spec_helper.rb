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
  config.warnings = false
  config.default_formatter = "doc" if config.files_to_run.one?
  config.order = :random
  Kernel.srand config.seed
end

require "internal/rails_app/config/environment"
require "rspec/rails"
I18n.load_path << File.expand_path("support/locale/en.yml", __dir__)

require "pry" if Gem::Specification.detect { |s| s.name == "pry" }

Dir["#{File.dirname(__FILE__)}/support/*.rb"].each { |f| require f }

# load ORM related support modules
Dir["#{File.dirname(__FILE__)}/support/#{ACTIVE_VALIDATION_ORM}/*.rb"].each { |f| require f }

# Load models for selected ORM
require "active_validation/frameworks/#{ACTIVE_VALIDATION_ORM}"

# Define Orm agnostic models constants shortcuts

Check    = ActiveValidation::Check
Manifest = ActiveValidation::Manifest
