# frozen_string_literal: true

module ActiveValidation
  class Manifest < ActiveRecord::Base
    prepend Orm::UpdateErrors
    self.table_name = :active_validation_manifests

    has_many :checks
    accepts_nested_attributes_for :checks
  end
end
