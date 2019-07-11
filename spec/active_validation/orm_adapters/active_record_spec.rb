# frozen_string_literal: true

describe ActiveValidation::OrmAdapters::ActiveRecord do
  context "global configuration" do
    subject { ActiveValidation.config }

    it "is in the registry" do
      expect(subject.orm_adapters_registry).to be_registered(:active_record)
    end
  end

  context "default" do
    it "is not abstract" do
      expect(described_class.abstract).to be_falsey
    end

    it "does not contain '(abstract)' suffix" do
      expect(described_class.to_s).not_to match(/\(abstract\)\z/)
    end

    it "is initialised after setup" do
      described_class.initialised = false
      expect(subject.setup.class.initialised).to be_truthy
    end
  end
end
