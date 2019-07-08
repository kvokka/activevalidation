# frozen_string_literal: true

ENV["DB"] ||= "sqlite"

require "active_record"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)
ActiveRecord::Base.include_root_in_json = true

# The simplest way is to stick to minimal version for easy support
class ActiveRecord::Migration
  def self.current_version
    5.0
  end
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true

  config.before(:suite) do
    destination_root = File.expand_path("../../internal/active_record", __dir__)
    args = ["--force"]
    [
      ActiveRecord::Generators::ActiveValidationGenerator
    ].each { |klass| klass.start args, destination_root: destination_root }

    SpecMigrator.migrate
  end
end
