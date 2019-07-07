# frozen_string_literal: true

require "spec_helper"

RSpec.describe Check::ValidateWithMethod do
  it "provides the description of the validation class" do
    expect(described_class.argument_description).to match "^Should contain"
  end
end
