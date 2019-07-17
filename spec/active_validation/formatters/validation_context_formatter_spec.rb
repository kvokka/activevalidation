# frozen_string_literal: true

describe ActiveValidation::Formatters::ValidationContextFormatter do
  it "formats the name" do
    expect(described_class.call("42")).to eq "manifest42"
  end

  it "formats the name with on option" do
    expect(described_class.call("42", "create")).to eq "manifest42_create"
  end
end
