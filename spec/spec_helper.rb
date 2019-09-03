# frozen_string_literal: true

ENV["ORM"] = "active_record"

puts "\n==> ORM = #{ENV['ORM'].inspect}"

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

  config.before do
    ActiveValidation.configuration.verifiers_registry.clear
  end
end

require "active_validation"
require "pry"

# load ORM related support modules
require_relative "orm/#{ENV['ORM']}/setup"

# Load models for selected ORM

ActiveValidation.config.orm_adapter = ENV["ORM"]

Dir["#{File.dirname(__FILE__)}/support/*.rb"].each { |f| require f }
Dir["#{File.dirname(__FILE__)}/support/shared_examples/*.rb"].each { |f| require f }
Dir["#{File.dirname(__FILE__)}/support/matchers/*.rb"].each { |f| require f }
