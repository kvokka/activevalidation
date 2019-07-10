# frozen_string_literal: true

module OnlyWithActiveRecord
  extend ActiveSupport::Concern

  included do
    before do
      skip unless ENV["ACTIVE_VALIDATION_ORM"] == "active_record"
    end
  end
end