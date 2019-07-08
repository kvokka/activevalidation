# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActiveValidation::Check do
  %i[update update_attribute update_attributes].each do |method|
    it "should raise on #{method}" do
      expect { subject.send(method) }.to raise_error ActiveValidation::Orm::Errors::NotSupported
    end
  end
end
