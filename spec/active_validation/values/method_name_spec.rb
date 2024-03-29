# frozen_string_literal: true

describe ActiveValidation::Values::MethodName do
  context "::new" do
    %w[validates validates_with validate].each do |name|
      it("generate #{name}") { expect(described_class.new(name).value).to eq name }
      it("is a String #{name}") { expect(described_class.new(name).value).to be_a String }
    end

    context "raise" do
      let(:error_class) { ActiveValidation::Errors::UnsupportedMethodError }

      it("method is not allowed") { expect { described_class.new("bad").value }.to raise_error error_class }
    end
  end
end
