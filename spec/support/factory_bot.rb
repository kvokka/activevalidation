# frozen_string_literal: true

require "factory_bot"

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.definition_file_paths << "spec/orm/#{ENV['ORM']}/factories"
    FactoryBot.find_definitions
  end
end
