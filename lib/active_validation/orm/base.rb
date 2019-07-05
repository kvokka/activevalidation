# frozen_string_literal: true

module ActiveValidation
  module Orm
    class Base
      class << self
        delegate :to_sym, to: :to_s

        def all
          @all ||= Set.new
        end

        def inherited(base)
          all << base
        end

        def to_s
          name.demodulize.underscore
        end
      end
    end
  end
end

require "active_validation/orm/plugins/active_record"
require "active_validation/orm/plugins/mongoid"
