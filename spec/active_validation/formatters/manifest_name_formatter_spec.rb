# frozen_string_literal: true

describe ActiveValidation::Formatters::ManifestNameFormatter do
  it "formats the name" do
    expect(described_class.call("Test")).to eq "Manifest for Test"
  end
end
