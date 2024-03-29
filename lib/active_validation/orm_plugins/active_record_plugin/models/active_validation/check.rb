# frozen_string_literal: true

module ActiveValidation
  class Check < ActiveRecord::Base
    prepend ActiveValidation::Concerns::ProtectFromMutableInstanceMethods

    serialize :options

    self.table_name = :active_validation_checks
    self.store_full_sti_class = false

    belongs_to :manifest, inverse_of: :checks

    validates :argument, presence: true

    def method_name
      raise NotImplementedError, "abstract" unless self.class < Check

      self.class.name.demodulize.sub(/Method\z/, "").underscore
    end

    def method_name=(other)
      self.type = other.camelcase + "Method"
    end

    def to_internal_check
      json_options = { methods: %i[method_name], root: false }
      ActiveValidation::Internal::Models::Check.new as_json(json_options).to_options!
    end
  end
end
