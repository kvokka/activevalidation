# frozen_string_literal: true

require "spec_helper"
require "generator_spec/test_case"
require "generators/active_validation/install/install_generator"

# rubocop:disable RSpec/FilePath
RSpec.describe ActiveValidation::Generators::InstallGenerator, type: :generator do
  include GeneratorSpec::TestCase
  destination File.expand_path("../../tmp", __dir__)

  after { prepare_destination }

  describe "no ORM" do
    before { prepare_destination }

    let(:stderr) { capture(:stderr) { run_generator } }

    it "assert error message was displayed" do
      expect(stderr).to match("An ORM must be set to install ActiveValidation")
    end

    it "assert initializator file was not created" do
      expect(destination_root).to(have_structure do
                                    directory("config") do
                                      directory("initializers") do
                                        no_file "active_validation.rb"
                                      end
                                    end
                                  end)
    end
  end

  describe "ActiveRecord" do
    before do
      prepare_destination
      run_generator %w[--orm=active_record]
    end

    it "assert all files are properly created" do
      expect(destination_root).to(have_structure do
        directory("config") do
          directory("initializers") do
            file "active_validation.rb" do
              contains "ActiveValidation.setup"
            end
          end
        end
      end)
    end
  end
end

# rubocop:enable RSpec/FilePath
