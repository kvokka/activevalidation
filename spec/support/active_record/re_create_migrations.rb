# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do
    next true if `git ls-files --modified lib/generators/active_record`.blank?

    require "generator_spec/test_case"
    require "generators/active_record/active_validation_generator"
    RSpec.describe ActiveRecord::Generators::ActiveValidationGenerator, type: :generator do
      include GeneratorSpec::TestCase
      destination File.expand_path("rails_app", __dir__)

      it("Re-run migrations in rails app") { run_generator ["--force"] }
    end
  end
end
