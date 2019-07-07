# frozen_string_literal: true

module ActiveValidation
  class Check < ActiveRecord::Base
    sti_autoload_path = "active_validation/frameworks/active_record/models/active_validation/check/"
    autoload :ValidateMethod,     "#{sti_autoload_path}validate_method"
    autoload :ValidateWithMethod, "#{sti_autoload_path}validate_with_method"
    autoload :ValidatesMethod,    "#{sti_autoload_path}validates_method"

    prepend Orm::Errors::Update

    self.table_name = :active_validation_checks
    self.store_full_sti_class = false

    belongs_to :manifest, inverse_of: :checks

    validates :argument, presence: true

    class << self
      def argument_description
        raise Orm::Errors::NotImplemented
      end
    end
  end
end
