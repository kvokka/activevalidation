# frozen_string_literal: true

require "rspec/core"
require "rspec/matchers"
require "active_validation/frameworks/rspec/helpers"

RSpec.configure do |config|
  config.include ::ActiveValidation::RSpec::Helpers::InstanceMethods
  config.extend  ::ActiveValidation::RSpec::Helpers::ClassMethods
end
