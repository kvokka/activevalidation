# frozen_string_literal: true

# The simplest way is to stick to minimal version for easy support
class ActiveRecord::Migration
  def self.current_version
    5.0
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    destination_root = File.expand_path("../../rails_app", __dir__)
    args = ["--force"]
    [
      ActiveRecord::Generators::ActiveValidationGenerator
    ].each { |klass| klass.start args, destination_root: destination_root }
  end
end
