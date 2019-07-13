# frozen_string_literal: true

describe ActiveValidation::Manifest, helpers: %i[only_with_active_record] do
  %i[update update_attribute update_attributes].each do |method|
    it "should raise on #{method}" do
      expect { subject.send(method) }.to raise_error ActiveValidation::Errors::ImmutableError
    end
  end

  context "with existed model" do
    before do
      define_model("Foo") { def foo_allowed; end }
      define_const("FooValidator", superclass: ActiveModel::Validator)
    end

    it "accepts nested attributes for checks" do
      described_class.create name: "foo's manifest", version: 1, model_klass: "Foo", checks_attributes: [
        { type: "ValidatesMethod", argument: :color, options: { presence: true } },
        { type: "ValidateWithMethod", argument: :FooValidator },
        { type: "ValidateMethod", argument: :foo_allowed }
      ]

      expect(described_class.count).to eq 1
      expect(ActiveValidation::Check.count).to eq 3
    end
  end

  context "factories traits" do
    %i[validate validates validate_with].each do |trait|
      it "accept Factory trait #{trait} and build corresponding check" do
        expect(build(:manifest, trait).checks.size).to eq 1
      end
    end
  end
end
