# frozen_string_literal: true

describe ActiveValidation::Check, helpers: %i[only_with_active_record] do
  it "return empty collection" do
    expect(described_class.all).to be_empty
  end

  %i[update update_attribute update_attributes].each do |method|
    it "should raise on #{method}" do
      expect { subject.send(method) }.to raise_error ActiveValidation::OrmAdapters::Errors::ImmutableError
    end
  end
end
