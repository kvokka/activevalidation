# frozen_string_literal: true

require "spec_helper"

return unless ACTIVE_VALIDATION_ORM == :active_record

require "generator_spec/test_case"
require "generators/active_record/active_validation_generator"

# rubocop:disable RSpec/FilePath
RSpec.describe ActiveRecord::Generators::ActiveValidationGenerator, type: :generator do
  include GeneratorSpec::TestCase
  destination File.expand_path("../../tmp", __dir__)

  after { prepare_destination }

  before { prepare_destination }

  # rubocop:disable RSpec/ExampleLength
  describe "no options" do
    before { run_generator }

    it "creates the migration" do
      expect(destination_root).to(
        have_structure do
          directory("db") do
            directory("migrate") do
              migration("create_active_validations") do
                contains("class CreateActiveValidations < " + SpecMigrator.migration_superclass)
                contains "def change"
                contains "create_table :active_validation_manifests"
                contains "create_table :active_validation_checks"
              end
            end
          end
        end
      )
    end
  end

  describe "with custom file name" do
    before { run_generator %w[foo] }

    it "creates the migration" do
      expect(destination_root).to(
        have_structure do
          directory("db") do
            directory("migrate") do
              migration("create_foo") do
                contains("class CreateFoo < " + SpecMigrator.migration_superclass)
                contains "def change"
                contains "create_table :active_validation_manifests"
                contains "create_table :active_validation_checks"
              end
            end
          end
        end
      )
    end
  end

  describe "with primary key option" do
    before { run_generator %w[--primary_key_type=uuid] }

    it "creates the migration" do
      expect(destination_root).to(
        have_structure do
          directory("db") do
            directory("migrate") do
              migration("create_active_validations") do
                contains("class CreateActiveValidations < " + SpecMigrator.migration_superclass)
                contains "def change"
                contains "create_table :active_validation_manifests, id: :uuid"
                contains "create_table :active_validation_checks, id: :uuid"
                contains "t.references :manifest, type: :uuid"
              end
            end
          end
        end
      )
    end
  end

  # rubocop:enable RSpec/ExampleLength
end
# rubocop:enable RSpec/FilePath
