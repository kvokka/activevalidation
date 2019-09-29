# frozen_string_literal: true

module ActiveValidation
  module Ext
    module AddActiveValidationContextCheck
      def valid?(*_args)
        result = super
        return result unless ActiveValidation.config.verifiers_registry.registered?(self.class)

        av_context = ActiveValidation.config.verifiers_registry[self.class].current_manifest.try(:context)
        return result unless av_context

        self.validation_context = av_context
        run_validations!
      end

      alias validate valid?
    end
  end
end
