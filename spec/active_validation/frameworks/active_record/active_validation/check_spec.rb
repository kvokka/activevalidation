# frozen_string_literal: true

describe ActiveValidation::Check do
  it "return empty collection" do
    expect(described_class.all).to be_empty
  end

  %i[update update_attribute update_attributes].each do |method|
    it "should raise on #{method}" do
      expect { subject.send(method) }.to raise_error ActiveValidation::Orm::Errors::NotSupported
    end
  end
end
