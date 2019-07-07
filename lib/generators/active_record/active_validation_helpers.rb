# frozen_string_literal: true

module ActiveRecord
  module Generators
    module ActiveValidationHelpers
      private

      def migration_path
        return db_migrate_path if Rails.version >= "5.0.3"

        @migration_path ||= File.join("db", "migrate")
      end

      def migration_version
        "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
      end

      def primary_key_type
        options[:primary_key_type]
      end
    end
  end
end
