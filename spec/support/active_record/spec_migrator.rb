# frozen_string_literal: true

class SpecMigrator
  class << self
    def new(*)
      raise NotImplemented
    end

    def migrate
      if ::ActiveRecord.gem_version >= ::Gem::Version.new("5.2.0.rc1")
        ::ActiveRecord::MigrationContext.new(migrations_path).migrate
      else
        ::ActiveRecord::Migrator.migrate(migrations_path)
      end
    end

    def migration_superclass
      "ActiveRecord::Migration" + migration_version_suffix
    end

    private

    def migration_version_suffix
      "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
    end

    def migrations_path
      @migrations_path ||= Pathname.new(File.expand_path("../../rails_app/db/migrate", __dir__))
    end

    def generate(generator, generator_invoke_args)
      sleep_until_the_next_second if @second_run_of_generator
      @second_run_of_generator = true
      Rails::Generators.invoke(generator, generator_invoke_args, destination_root: Rails.root)
    end

    # we need it to avoid the creation of migrations in the same second
    def sleep_until_the_next_second
      t = Time.now.to_i
      sleep(0.001) while Time.now.to_i == t
    end
  end
end
