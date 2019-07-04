# frozen_string_literal: true

module ActiveValidation
  module Orm
    require "active_validation/orm/base"
    require "active_validation/orm/active_record"
    require "active_validation/orm/mongoid"

    class NotSupportedOrm < StandardError; end

    module_function

    def find!(name)
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
