# frozen_string_literal: true

module OnlyWithActiveRecord
  extend ActiveSupport::Concern

  included do
    before do
      skip unless ENV["ORM"] == "active_record"
    end
  end
end

RSpec.configure do |config|
  config.include OnlyWithActiveRecord, helpers: :only_with_active_record
end
