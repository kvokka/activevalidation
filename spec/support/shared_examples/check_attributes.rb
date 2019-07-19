# frozen_string_literal: true

RSpec.shared_examples "check attributes check" do |_parameter|
  it "repteresnts itself as HashWithIndifferentAccess" do
    expect(subject.with_indifferent_access).to be_a ActiveSupport::HashWithIndifferentAccess
  end

  %w[argument options manifest_id].each do |field|
    it "should contain field #{field}" do
      expect(subject.attributes).to have_key(field)
    end
  end

  context "as ActiveSupport::HashWithIndifferentAccess" do
    %w[argument options manifest_id method_name].each do |field|
      it "should contain field #{field}" do
        expect(subject.with_indifferent_access).to have_key(field)
      end
    end
  end
end
