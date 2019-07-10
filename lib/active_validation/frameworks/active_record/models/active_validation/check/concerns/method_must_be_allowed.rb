# frozen_string_literal: true

module ActiveValidation::Check::Concerns::MethodMustBeAllowed
  extend ActiveSupport::Concern

  included do
    validate :method_must_be_allowed
  end

  module ClassMethods
    # list of restricted methods in the checking instance
    def validation_restricted_methods
      %i[
        delete
        destroy
        destroy_all
        touch
        update
        update!
        update_all
        update_attribute
        update_attributes
        update_column
        update_columns
      ]
    end
  end

  private

  def method_must_be_allowed
    verify_options
    verify_argument
    verify_glogal_argument
  end

  def verify_options
    return unless options

    danger_values = options.slice([:if, :unless, "if", "unless"]).values
    return if (danger_values & self.class.validation_restricted_methods).empty?

    errors.add :options, "Options contain dangerous checks"
  end

  def verify_argument
    return unless argument && manifest.try(:model_klass)
    return unless self.class.validation_restricted_methods.include?(argument.to_sym)

    errors.add :argument, "method #{argument} is globally restricted for usage in validation"
  end

  def verify_glogal_argument
    return unless argument && manifest.try(:model_klass)

    model_restricted_methods = Array(manifest.model_class.try(:validation_restricted_methods)).map(&:to_sym)
    return unless model_restricted_methods.include?(argument.to_sym)

    errors.add :argument, "method #{argument} is restricted for usage in validation"
  end
end
