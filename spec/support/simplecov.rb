# frozen_string_literal: true

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.command_name "RSpec"
  SimpleCov.start
  SimpleCov.at_exit do
    @exit_status = 0
    SimpleCov.result.format!
  end
end
