# frozen_string_literal: true

module ActiveRecordConnection
  module_function

  def call(db = ENV["DB"])
    relative_path = "../db_adapters/database.#{db}.yml"
    full_path = File.expand_path(relative_path, File.dirname(__FILE__))

    # Keep the format of database.*.yml files similar with multi-env configs
    # intentionally. It provide simpler support

    ActiveRecord::Base.establish_connection YAML.load_file(full_path).fetch("test")
  end
end
