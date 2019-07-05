# frozen_string_literal: true

module ActiveValidation
  module Orm
    require "active_validation/orm/base"
    autoload :Finder, "active_validation/orm/finder"
  end
end
