# frozen_string_literal: true

describe ActiveValidation::Check, helpers: %i[only_with_active_record] do
  it "return empty collection" do
    expect(described_class.all).to be_empty
  end

  %i[update update_attribute update_attributes].each do |method|
    it "should raise on #{method}" do
      expect { subject.send(method) }.to raise_error ActiveValidation::Errors::ImmutableError
    end
  end

  context "arstract" do
    it "expect to raise on ::argument_description" do
      expect { described_class.argument_description }.to raise_error NotImplementedError
    end
  end

  context "::method_name" do
    it "expect to raise on ::argument_description" do
      expect { described_class.new.method_name }.to raise_error NotImplementedError
    end

    it "return right name" do
      klass = define_const "FooMethod", superclass: ActiveValidation::Check
      expect(klass.new.method_name).to eq "foo"
    end
  end

  context "with_indifferent_access" do
    it "raises an error as abstract class" do
      expect { subject.with_indifferent_access }.to raise_error NotImplementedError
    end
  end
end
