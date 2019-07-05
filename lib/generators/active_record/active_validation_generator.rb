# frozen_string_literal: true

require "rails/generators/active_record"
require "generators/active_record/active_validation_helpers"

module ActiveRecord
  module Generators
    class ActiveValidationGenerator < ActiveRecord::Generators::Base
      class_option :primary_key_type, type: :string, desc: "The type for primary key", default: :integer

      argument :name, type: :string, default: "active_validations",
               desc: "Customize file name for the migration"

      include ActiveRecord::Generators::ActiveValidationHelpers
      source_root File.expand_path("templates", __dir__)

      def copy_migration
        migration_template "migration.rb.erb", "#{migration_path}/create_#{name}.rb",
                           migration_version: migration_version
      end
    end
  end
end
