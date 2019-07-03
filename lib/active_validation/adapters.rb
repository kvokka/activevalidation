# frozen_string_literal: true

module ActiveValidation
  module Adapters
    class << self
      def all
        @all ||= []
      end
    end
  end
end
