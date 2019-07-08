# frozen_string_literal: true

module ActiveValidation
  class Check < ActiveRecord::Base
    sti_autoload_path = "active_validation/frameworks/active_record/models/active_validation/check/"
    autoload :ValidateMethod,     "#{sti_autoload_path}validate_method"
    autoload :ValidateWithMethod, "#{sti_autoload_path}validate_with_method"
    autoload :ValidatesMethod,    "#{sti_autoload_path}validates_method"

    prepend Orm::Errors::Update

    self.table_name = :active_validation_checks

    belongs_to :manifest
  end
end
