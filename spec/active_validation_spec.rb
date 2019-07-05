# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActiveValidation do
  it ".config method return actual Configuration" do
    expect(subject.config).to eq ActiveValidation::Configuration.instance
  end
end
