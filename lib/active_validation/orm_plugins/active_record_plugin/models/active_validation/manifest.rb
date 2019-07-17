# frozen_string_literal: true

module ActiveValidation
  class Manifest < ActiveRecord::Base
    prepend ActiveValidation::Concerns::ProtectFromMutableInstanceMethods

    self.table_name = :active_validation_manifests

    attribute :version, :version

    has_many :checks
    accepts_nested_attributes_for :checks, allow_destroy: false

    def model_class
      base_klass.constantize
    end

    def with_indifferent_access
      ActiveSupport::HashWithIndifferentAccess.new as_json(include: :checks, root: false)
    end
  end
end

::ActiveRecord::Type.register(:version, ActiveValidation::Type::Version)
