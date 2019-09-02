# frozen_string_literal: true

module ActiveValidation
  module ModelExtensionBase
    extend ActiveSupport::Concern
    module ClassMethods
      # This is entry point, which setup or return existed Verifier.
      #
      # @return Verifier
      def active_validation(&block)
        register_active_validation_relations unless ActiveValidation::Verifier.registry.registered? self
        ::ActiveValidation::Verifier.find_or_build self, &block
      end

      private

      # Invoke the checks that validations are in place. Should be overwritten in ORM
      # adapter
      #
      # @return nil
      def register_active_validation_relations; end
    end

    protected

    # We need to be sure, that all validation call backs are in place before validation
    #
    # @return nil
    def process_active_validation
      ::ActiveValidation::Verifier.find_or_build(self.class).install!(manifest_id: manifest_id)
    end
  end
end
