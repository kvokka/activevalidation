# frozen_string_literal: true

module ActiveValidation
  module Orm
    class Mongoid < Base
      class << self
        def setup
          ::ActiveSupport.on_load(:mongoid) do
            ::Mongoid::Document.include ActiveValidation::ModelExtension
          end
        end
      end
    end
  end
end
