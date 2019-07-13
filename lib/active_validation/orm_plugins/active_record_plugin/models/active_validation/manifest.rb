# frozen_string_literal: true

module ActiveValidation
  class Manifest < ActiveRecord::Base
    prepend ActiveValidation::Concerns::ProtectFromMutableInstanceMethods

    self.table_name = :active_validation_manifests

    attribute :version, :api_version

    has_many :checks
    accepts_nested_attributes_for :checks, allow_destroy: false

    def model_class
      base_klass.constantize
    end
  end
end

::ActiveRecord::Type.register(:api_version, ActiveValidation::Type::ApiVersion)
