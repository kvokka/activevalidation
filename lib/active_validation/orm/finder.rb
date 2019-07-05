# frozen_string_literal: true

require "active_validation/orm/base"

module ActiveValidation
  module Orm
    module Finder
      class NotSupportedOrm < StandardError; end

      module_function

      def call(name)
        case name
        when Class
          Base.all.detect { |f| f == name } or raise NotSupportedOrm
        when String, Symbol
          Base.all.detect { |f| f.to_s == name.to_s } or raise NotSupportedOrm
        else
          raise ArgumentError
        end.tap(&:setup)
      end
    end
  end
end
