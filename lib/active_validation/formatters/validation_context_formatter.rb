# frozen_string_literal: true

module ActiveValidation
  module Formatters
    class ValidationContextFormatter
      class << self
        def call(*args)
          new(*args).call
        end
      end

      def initialize(manifest)
        @manifest = manifest
      end

      attr_reader :manifest

      delegate :options, :id, :name, to: :manifest

      def call
        ["active_validation", "id#{id}"].tap do |base|
          base << "on_#{options[:on]}" if options[:on]
          base << name.to_s.underscore unless name.blank?
        end.join("_")
      end
    end
  end
end
