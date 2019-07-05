# frozen_string_literal: true

module ActiveValidation
  module Orm
    module Plugins
      class ActiveRecord < Base
        class << self
          def setup
            ::ActiveSupport.on_load(:active_record) do
              ActiveValidation::ActiveRecord.base.include(ActiveValidation::ModelExtension)
            end
          end
        end
      end
    end
  end
end
