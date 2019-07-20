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

    %i[method_name argument options].each do |attr|
      it("should have '#{attr}' attribute") { expect(Hash(subject)[attr]).to be_truthy }
    end
  end

  it "is equal" do
    check1 = described_class.new method_name: "validates", argument: "name", options: { name: "foo" }
    check2 = described_class.new method_name: "validates", argument: "name", options: { name: "foo" }
    expect(check1).to eq check2
  end
end
