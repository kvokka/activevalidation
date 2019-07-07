# frozen_string_literal: true

require "spec_helper"

return unless ACTIVE_VALIDATION_ORM == :active_record

RSpec.describe ActiveValidation::Check do
  it "return empty collection" do
    expect(described_class.all).to be_empty
  end
end
