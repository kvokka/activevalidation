# frozen_string_literal: true

RSpec.shared_examples "check attributes check" do |_parameter|
  %w[argument options manifest_id].each do |field|
    it "contains field #{field}" do
      expect(subject.attributes).to have_key(field)
    end
  end
end
