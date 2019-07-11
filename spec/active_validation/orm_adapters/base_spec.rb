# frozen_string_literal: true

describe ActiveValidation::OrmAdapters::Base do
  context "global configuration" do
    subject { ActiveValidation.config }

    it "is in the registry" do
      expect(subject.orm_adapters_registry).not_to be_registered(:base)
    end
  end

  it "contains '(abstract)' suffix" do
    expect(described_class.to_s).to match(/\(abstract\)\z/)
  end
end
