# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActiveValidation do
  it ".config method return actual Configuration" do
    expect(subject.config).to be_a ActiveValidation::Configuration
  end

  it "setups proper default adapter" do
    expect(subject.configuration.orm_adapter.to_s).to eq "#{ENV['ORM']}_plugin"
  end

  context "verifier_defaults" do
    it "does not raise if no block provided" do
      expect { subject.configuration.verifier_defaults }.not_to raise_error
    end
  end
end
