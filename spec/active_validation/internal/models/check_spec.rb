# frozen_string_literal: true

describe ActiveValidation::Internal::Models::Check do
  subject { described_class.new method_name: "validates", argument: "name" }

  let(:registry) { ActiveValidation.config.method_name_values_registry }

  %i[method_name argument options created_at].each do |m|
    it { is_expected.to have_attr_reader m }
  end

  it "converts the method name to value object" do
    expect(subject.method_name).to be_a ActiveValidation::Values::MethodName
  end

  it "add method name to the registry" do
    registry.clear
    subject
    expect(registry.count).to eq 1
  end

  context "#to_hash" do
    it "converts to Hash with out coercion" do
      expect { Hash(subject) }.not_to raise_error
    end
  end

  context "#as_json" do
    %i[method_name argument options].each do |attr|
      it("should have '#{attr}' attribute") { expect(subject.as_json[attr]).to be_truthy }
    end

    it "works correctly with out 'only' option" do
      expect(subject.as_json).to eq subject.to_hash
    end

    it "produce right output with 'only' option argument" do
      expect(subject.as_json(only: [:argument])).to eq(argument: "name")
    end

    it "produce right output with 'only' option created_at" do
      check = described_class.new method_name: "validates", argument: "name", created_at: "10AM"
      expect(check.as_json(only: [:created_at])).to eq(created_at: "10AM")
    end
  end

  context "#to_send_arguments" do
    %i[validate validates].each do |m|
      it "set for #{m}" do
        check = described_class.new method_name: m, argument: "name", options: { name: "foo" }
        expect(check.to_send_arguments).to match_array [m, :name, { name: "foo" }]
      end
    end

    it "set for validates_with" do
      define_const "MyValidator", superclass: ActiveModel::Validator
      check = described_class.new method_name: :validates_with, argument: "MyValidator", options: { name: "foo" }
      expect(check.to_send_arguments).to match_array [:validates_with, MyValidator, { name: "foo" }]
    end
  end

  it "is equal" do
    check1 = described_class.new method_name: "validates", argument: "name", options: { name: "foo" }
    check2 = described_class.new method_name: "validates", argument: "name", options: { name: "foo" }
    expect(check1).to eq check2
  end
end
