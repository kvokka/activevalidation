# frozen_string_literal: true

ENV["DB"] ||= "sqlite"

require "active_record"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)
ActiveRecord::Base.include_root_in_json = true

SpecMigrator.migrate

# In rails < 5, some tests seem to require DatabaseCleaner-truncation.
# Truncation is about three times slower than transaction rollback, so it'll
# be nice when we can drop support for rails < 5.

if ::ActiveRecord.gem_version < ::Gem::Version.new("5")
  require "database_cleaner"
  DatabaseCleaner.strategy = :truncation
  RSpec.configure do |config|
    config.use_transactional_fixtures = false
    config.before { DatabaseCleaner.start }
    config.after { DatabaseCleaner.clean }
  end
else
  RSpec.configure do |config|
    config.use_transactional_fixtures = true
  end
end
