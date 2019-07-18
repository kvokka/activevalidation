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

    def method_name
      raise NotImplementedError, "abstract" unless self.class < Check

      self.class.name.demodulize.sub(/Method\z/, "").underscore
    end
  end
end
