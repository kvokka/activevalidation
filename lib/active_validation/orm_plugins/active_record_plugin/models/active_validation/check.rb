# frozen_string_literal: true

module ActiveValidation
  class Check < ActiveRecord::Base
    prepend ActiveValidation::Concerns::ProtectFromMutableInstanceMethods

    self.table_name = :active_validation_checks
    self.store_full_sti_class = false

    belongs_to :manifest, inverse_of: :checks

    validates :argument, presence: true

    class << self
      def argument_description
        raise NotImplementedError, "abstract"
      end
    end
  end
end
