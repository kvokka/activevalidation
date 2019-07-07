# frozen_string_literal: true

module ActiveValidation
  module Orm
    require "active_validation/orm/base"
    autoload :Finder, "active_validation/orm/finder"
    autoload :UpdateErrors, "active_validation/orm/update_errors"
  end
end
