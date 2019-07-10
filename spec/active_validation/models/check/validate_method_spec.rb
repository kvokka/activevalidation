# frozen_string_literal: true

describe Check::ValidateMethod do
  it "provides the description of the validation class" do
    expect(described_class.argument_description).to match "^Should contain"
  end

  context "validate the method invocation" do
    it "invokes allowed method" do
      expect(build(:check_validate, argument: "foo_allowed")).to be_valid
    end

    it "does not invoke globally restricted method" do
      manifest = build :manifest, model_klass: "Fruit"
      expect(build(:check_validate, argument: "delete", manifest: manifest)).not_to be_valid
    end
  end
end
