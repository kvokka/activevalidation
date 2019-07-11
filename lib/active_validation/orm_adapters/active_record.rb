# frozen_string_literal: true

module ActiveValidation
  module OrmAdapters
    class ActiveRecord < Base
      class << self
        def setup
          return initialised if initialised

          if defined? ::ActiveRecord::Base
            ::ActiveRecord::Base.include ActiveValidation::ModelExtension
          else
            ::ActiveSupport.on_load(:active_record) do
              ::ActiveRecord::Base.include(ActiveValidation::ModelExtension)
            end
          end

          self.initialised = true
        end

        def restricted_instance_methods
          (mutable_instance_methods + %i[delete destroy destroy_all]).freeze
        end

        def mutable_instance_methods
          %i[
            touch
            update
            update!
            update_all
            update_attribute
            update_attributes
            update_column
            update_columns
          ].freeze
        end
      end

      # By design all records must be immutable. I do not recommend to avoid
      # this restriction
      module ProtectFromMutableInstanceMethods
        ActiveRecord.mutable_instance_methods.each do |name|
          define_method(name) { raise Errors::ImmutableError }
        end
      end

      def initialize; end

      def setup
        self.class.setup && self
      end
    end
  end
end
