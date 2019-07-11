# frozen_string_literal: true

ENV["ACTIVE_VALIDATION_ORM"] ||= "active_record"

$LOAD_PATH.unshift File.dirname(__FILE__)
puts "\n==> ACTIVE_VALIDATION_ORM = #{ENV['ACTIVE_VALIDATION_ORM'].inspect}"

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

require "active_validation"
require "active_support/concern"
require "pry"

Dir["#{File.dirname(__FILE__)}/support/*.rb"].each { |f| require f }

# load ORM related support modules
require_relative "support/orm/#{ENV['ACTIVE_VALIDATION_ORM']}/setup"

# Load models for selected ORM

ActiveValidation.config.orm_adapter = ENV["ACTIVE_VALIDATION_ORM"]
