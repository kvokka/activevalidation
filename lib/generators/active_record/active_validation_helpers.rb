# frozen_string_literal: true

module ActiveRecord
  module Generators
    module ActiveValidationHelpers
      private

      def migration_path
        return db_migrate_path if Rails.version >= "5.0.3"

        @migration_path ||= File.join("db", "migrate")
      end

      def rails_gt_4?
        Rails::VERSION::MAJOR > 4
      end

      def migration_version
        "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]" if rails_gt_4?
      end

      def create_table_primary_key_type
        return nil unless rails_gt_4?

        ", id: :#{primary_key_type}" if primary_key_type
      end

      def references_primary_key_type
        return nil unless rails_gt_4?

        ", type: :#{primary_key_type}" if primary_key_type
      end

      def primary_key_type
        options[:primary_key_type]
      end
    end
  end
end
