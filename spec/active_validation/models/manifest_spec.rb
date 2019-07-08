# frozen_string_literal: true

require "spec_helper"

RSpec.describe Manifest do
  %i[update update_attribute update_attributes].each do |method|
    it "should raise on #{method}" do
      expect { subject.send(method) }.to raise_error ActiveValidation::Orm::Errors::NotSupported
    end
  end

  it "accepts nested attributes for checks" do
    described_class.create name: "foo", version: 1, model_klass: "Fruit", checks_attributes: [
      { type: "ValidatesMethod", argument: :color, options: { presence: true } },
      { type: "ValidateWithMethod", argument: :FooValidator },
      { type: "ValidateMethod", argument: :foo_allowed }
    ]

    expect(described_class.count).to eq 1
    expect(Check.count).to eq 3
  end

  context "factories traits" do
    %i[validate validates validate_with].each do |trait|
      it "accept Factory trait #{trait} and build corresponding check" do
        expect(build(:manifest, trait).checks.size).to eq 1
      end
    end
  end
end
