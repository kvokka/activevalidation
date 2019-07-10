# frozen_string_literal: true

ENV["DB"] ||= "sqlite"

require "active_record"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)
ActiveRecord::Base.include_root_in_json = true

require_relative "macros/define_constant"
require_relative "macros/active_record_connection"

RSpec.configure do |config|
  config.include DefineConstantMacros
  config.include ActiveRecordConnection

  config.before do
    ActiveRecordConnection.call

    create_table :active_validation_manifests do |t|
      t.string   :name
      t.string   :version
      t.string   :model_klass

      t.datetime :created_at
    end

    create_table :active_validation_checks do |t|
      t.integer    :manifest_id
      t.string     :type
      t.string     :argument

      t.json       :options

      t.datetime   :created_at
    end
  end
end
