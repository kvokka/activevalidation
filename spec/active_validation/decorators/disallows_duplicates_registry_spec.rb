# frozen_string_literal: true

describe ActiveValidation::Decorators::DisallowsDuplicatesRegistry do
  subject { described_class.new(registry) }

  let(:registry) { ActiveValidation::Registry.new("Great thing") }
  let(:error_class) { ActiveValidation::Errors::DuplicateRegistryEntryError }

  let(:registered_object)        { instance_double("registered object") }

  it "finds a registered object" do
    subject.register(:object_name, registered_object)
    expect { subject.register(:object_name, registered_object) }.to raise_error error_class
  end
end
