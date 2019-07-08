# frozen_string_literal: true

module ActiveValidation
  class Manifest < ActiveRecord::Base
    prepend Orm::Errors::Update
    self.table_name = :active_validation_manifests

    has_many :checks
    accepts_nested_attributes_for :checks, allow_destroy: false

    def model_class
      model_klass.constantize
    end
  end
end
