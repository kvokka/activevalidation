# frozen_string_literal: true

module ActiveValidation
  class Manifest < ActiveRecord::Base
    module Decorators
      class ToJsonWithNested < ActiveValidation::Decorator
        def initialize(component)
          super(component)
        end

        def as_json
          ActiveSupport::HashWithIndifferentAccess.new super(include: :checks, root: false)
        end
      end
    end
  end
end
