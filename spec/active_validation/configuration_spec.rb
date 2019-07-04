# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActiveValidation::Configuration do
  it "setups proper default adapter" do
    expect(ActiveValidation.configuration.orm.to_sym).to eq ACTIVE_VALIDATION_ORM
  end
end
