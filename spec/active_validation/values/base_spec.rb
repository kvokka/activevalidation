# frozen_string_literal: true

describe ActiveValidation::Values::Base do
  subject { described_class.new("42") }

  context "Set" do
    it("value") { expect(described_class.new(1).value).to eq 1 }
  end

  context "Get" do
    it("value") { expect(subject.value).to eq "42" }
  end

  context "raise" do
    [nil, true, false].each do |el|
      it("from #{el}") { expect { described_class.new(el).value }.to raise_error ArgumentError }
    end
  end

  context "<=>" do
    subject { %i[1 5 9 3 7].map { |n| described_class.new n } }

    it("sort") { expect(subject.sort.map(&:to_s)).to eq %w[1 3 5 7 9] }
  end

  context "==" do
    let(:version1) { described_class.new 1 }
    let(:another_version1) { described_class.new 1 }

    it("is equal") { expect(version1).to eq another_version1 }
    it("is not equal") { expect(version1).not_to eq subject }
  end

  context "to_s" do
    it("convert to integer to string") { expect(described_class.new(1).to_s).to eq "1" }
    it("convert to symbol to string") { expect(described_class.new(:foo).to_s).to eq "foo" }
  end

  context "to_json" do
    it("return only value") { expect(described_class.new(42).to_json).to eq "42" }
  end

  context "as_json" do
    it("return only value") { expect(described_class.new(42).as_json).to eq 42 }
  end
end
