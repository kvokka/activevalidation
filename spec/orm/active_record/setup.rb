# frozen_string_literal: true

require "active_record"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)
ActiveRecord::Base.include_root_in_json = true

require_relative "prepare_db"

PrepareDb.call
