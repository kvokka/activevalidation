# frozen_string_literal: true

# At this moment there is only Active record Plugin, so it is
# used in the Readme files for examples.

# rubocop:disable RSpec/DescribeClass
# rubocop:disable RSpec/ExampleLength
describe "Readme" do
  let(:manifest) do
    {
      base_klass:        "Foo", # Name of the Model Class
      version:           1, # optional, by default use locked or latest version
      name:              "awesome-foo", # optional, some name for easier managing

      # the syntax is the same with ActiveModel. For :validates_with and :validate `options` field is optional
      checks_attributes: [
        { method_name: "validates", argument: "my_method", options: { presence: true } },
        { method_name: "validates_with", argument: "MyValidator" },
        { method_name: "validate", argument: "my_validation_method" }
      ]
    }
  end

  let(:empty_manifest) do
    {
      base_klass:        "Foo", # Name of the Model Class
      checks_attributes: []
    }
  end

  before do
    define_const("Foo", superclass: ActiveRecord::Base) do
      active_validation

      def my_method; end

      def my_validation_method
        errors.add(:base, "we'd called validation method")
      end
    end

    define_const("MyValidator", superclass: ActiveModel::Validator) do
      def validate(*); end
    end

    define_const "Foo::Validations::V1"
  end

  it "manifest manipulations" do
    # This is how you can add the new manifest
    Foo.active_validation.add_manifest(manifest)

    f = Foo.new

    expect(f).not_to be_valid
    expect(f.errors.messages).to have_key(:my_method)
    expect(f.errors.messages).to have_key(:base)

    # new manifest will be used for new records, while existed records
    # continue using one of the previous versions
    Foo.active_validation.add_manifest(empty_manifest)

    expect(f).to be_valid

    # get all manifests for current version
    manifests = Foo.active_validation.find_manifests

    expect(manifests.size).to eq 2

    # we can specify version, if we want to
    Foo.active_validation.find_manifests version: 42

    # Get the latest manifest
    manifest = Foo.active_validation.find_manifest

    # we can con edit existed manifests, but we can easily
    # create the new one based on the existed
    Foo.active_validation.add_manifest(manifest.as_json.tap do |m|
      m[:name] = "Something"
      m[:id] = nil
    end)

    expect(Foo.active_validation.find_manifest.name).to eq "Something"
  end
end
# rubocop:enable RSpec/DescribeClass
# rubocop:enable RSpec/ExampleLength
