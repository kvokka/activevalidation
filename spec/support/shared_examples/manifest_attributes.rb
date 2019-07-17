# frozen_string_literal: true

RSpec.shared_examples "manifest attributes check" do |_parameter|
  { base_klass: "Foo", name: "tst", version: 1, checks: [], created_at: Time.now }.each do |attr, value|
    it "raises no error with attribute #{attr}" do
      expect { subject.add_manifest(attr => value) }.not_to raise_error
    end
  end
end
