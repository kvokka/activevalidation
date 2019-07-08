# frozen_string_literal: true

module ActiveValidation
  module Orm
    require "active_validation/orm/base"
    autoload :Finder, "active_validation/orm/finder"
    autoload :Errors, "active_validation/orm/errors"
  end
end
