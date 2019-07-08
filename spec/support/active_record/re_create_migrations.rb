# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do
    generator_paths = %w[active_record]
                      .map { |s| "lib/generators/#{s}" }.join(" ")
    next true if `git ls-files --modified #{generator_paths}`.blank?

    destination_root = File.expand_path("../../rails_app", __dir__)
    args = ["--force"]
    [
      ActiveRecord::Generators::ActiveValidationGenerator
    ].each { |klass| klass.start args, destination_root: destination_root }
  end
end
