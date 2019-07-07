# frozen_string_literal: true

module ActiveValidation
  class Check < ActiveRecord::Base
    prepend Orm::UpdateErrors
    self.table_name = :active_validation_checks

    belongs_to :manifest
  end
end
