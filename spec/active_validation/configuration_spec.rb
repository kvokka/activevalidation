# frozen_string_literal: true

describe ActiveValidation::Configuration do
  it "setups proper default adapter" do
    expect(ActiveValidation.configuration.orm.to_sym).to eq ACTIVE_VALIDATION_ORM
  end

  context "verifier_defaults" do
    it "does not raise if no block provided" do
      expect { described_class.instance.verifier_defaults }.not_to raise_error
    end
  end
end
