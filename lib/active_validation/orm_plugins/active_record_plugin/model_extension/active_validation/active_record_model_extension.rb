# frozen_string_literal: true

module ActiveValidation
  module ActiveRecordModelExtension
    extend ActiveSupport::Concern
    include ModelExtensionBase

    module ClassMethods
      private

      def register_active_validation_relations
        before_validation :process_active_validation

        belongs_to :manifest, class_name: "::ActiveValidation::Manifest", dependent: :destroy

        ActiveValidation::Manifest.has_many realtion_plural_name
        nil
      end

      def realtion_plural_name
        name.underscore.pluralize.to_sym
      end
    end
  end
end
