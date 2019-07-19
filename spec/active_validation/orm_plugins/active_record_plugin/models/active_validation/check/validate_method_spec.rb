# frozen_string_literal: true

describe ActiveValidation::Check::ValidateMethod, helpers: %i[only_with_active_record] do
  it "provides the description of the validation class" do
    expect(described_class.argument_description).to match "^Should contain"
  end

  include_examples "check attributes check"

  it("contains field type") { expect(subject.attributes).to have_key("type") }

  context "validate the method invocation" do
    before do
      define_model "Foo" do
        def foo_allowed; end

        def foo_not_allowed; end
      end
    end

    it "invokes allowed method" do
      expect(build(:check_validate, argument: "foo_allowed")).to be_valid
    end

    it "does not invoke globally restricted method" do
      manifest = build :manifest, base_klass: "Foo"
      expect(build(:check_validate, argument: "delete", manifest: manifest)).not_to be_valid
    end
  end
end
