# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActiveValidation::Manifest do
  %i[update update_attribute update_attributes].each do |method|
    it "should raise on #{method}" do
      expect { subject.send(method) }.to raise_error ActiveValidation::Orm::UpdateErrors::NotSupported
    end
  end
end
