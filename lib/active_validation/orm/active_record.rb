# frozen_string_literal: true

module ActiveValidation
  module Orm
    class ActiveRecord < Base
      class << self
        def base
          ::ApplicationRecord
        rescue NameError
          ::ActiveRecord::Base
        end

        def setup
          ::ActiveSupport.on_load(:active_record) do
            ActiveValidation::Orm::ActiveRecord.base.include(ActiveValidation::ModelExtension)
          end
        end
      end
    end
  end
end
