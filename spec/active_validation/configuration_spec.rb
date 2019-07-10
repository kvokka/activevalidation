# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActiveValidation::Configuration do
  it "setups proper default adapter" do
    expect(ActiveValidation.configuration.orm.to_sym).to eq ACTIVE_VALIDATION_ORM
  end

  context "verifier_defaults" do
    it "does not raise if no block provided" do
      expect { described_class.instance.verifier_defaults }.not_to raise_error
    end

    it "store provided block" do
      vd = described_class.instance.verifier_defaults { |a| a * a }
      expect(vd.call(2)).to eq 4
    end
  end
end
