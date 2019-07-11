# frozen_string_literal: true

module ActiveValidation
  class Check < ActiveRecord::Base
    module Concerns
      module MethodMustBeAllowed
        extend ActiveSupport::Concern

        included do
          validate :method_must_be_allowed
        end

        private

        def method_must_be_allowed
          verify_options
          verify_argument
        end

        def verify_options
          return unless options

          danger_values = options.slice([:if, :unless, "if", "unless"]).values
          return if (danger_values & restricted_instance_methods).empty?

          errors.add :options, "Options contain dangerous checks"
        end

        def verify_argument
          return unless argument && manifest.try(:model_klass)
          return unless restricted_instance_methods.include?(argument.to_sym)

          errors.add :argument, "method #{argument} is restricted for usage in validation"
        end
      end
    end
  end
end
