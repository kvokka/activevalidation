# frozen_string_literal: true

describe ActiveValidation::BaseAdapter do
  context "global configuration" do
    subject { ActiveValidation.config }

    it "is in the registry" do
      expect(subject.orm_adapters_registry).not_to be_registered(:base)
    end
  end

  it "has 'base' plugin name" do
    expect(described_class.plugin_name).to eq "base"
  end

  it "has 'base' adapter name" do
    expect(described_class.adapter_name).to eq "base"
  end

  it "contains '(abstract)' suffix" do
    expect(described_class.to_s).to match(/\(abstract\)\z/)
  end
end
