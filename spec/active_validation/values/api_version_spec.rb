# frozen_string_literal: true

describe ActiveValidation::Values::ApiVersion do
  context "::new" do
    context 'with "V" prefix' do
      it("from symbol") { expect(described_class.new(:V42).value).to eq 42 }
      it("from string") { expect(described_class.new("V42").value).to eq 42 }
    end

    context 'with out "V" prefix' do
      it("from symbol") { expect(described_class.new(:'42').value).to eq 42 }
      it("from string") { expect(described_class.new("42").value).to eq 42 }
    end

    context "raise" do
      [nil, true, false, "Foo1", "V55A"].each do |el|
        it("from #{el}") { expect { described_class.new(el).value }.to raise_error ArgumentError }
      end
    end

    it("set the value from integer") { expect(described_class.new(42).value).to eq 42 }

    context "to_i" do
      it("string to integer") { expect(described_class.new("42").to_i).to eq 42 }
      it("symbol to integer") { expect(described_class.new("V42").to_i).to eq 42 }
    end
  end
end
