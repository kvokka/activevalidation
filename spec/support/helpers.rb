# frozen_string_literal: true

require_relative "helpers/only_with_active_record"

RSpec.configure do |config|
  config.include OnlyWithActiveRecord, helpers: :only_with_active_record
end
