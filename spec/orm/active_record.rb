# frozen_string_literal: true

ENV["DB"] ||= "sqlite"

require "active_record"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)
ActiveRecord::Base.include_root_in_json = true

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.before(:suite) do
    SpecMigrator.migrate
  end
end
