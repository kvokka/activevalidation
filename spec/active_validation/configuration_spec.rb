# frozen_string_literal: true

describe ActiveValidation::Configuration do
  it "has verifiers registry" do
    expect(subject.verifiers_registry).to be_a ActiveValidation::Registry
  end

  it "has ORM adapters registry" do
    expect(subject.orm_adapters_registry).to be_a ActiveValidation::Registry
  end

  context "manifest name formatter" do
    it "has value" do
      expect(subject.manifest_name_formatter).to eq ActiveValidation::Formatters::ManifestNameFormatter
    end

    it "has value" do
      expect(subject.manifest_name_formatter).to respond_to(:call)
    end
  end

  context "orm_adapter=" do
    let(:config) { ActiveValidation.config }

    context "with fake" do
      around do |tst|
        adapter = config.orm_adapter
        module ActiveValidation::OrmPlugins::FakePlugin; class Adapter < ActiveValidation::BaseAdapter; end; end
        tst.call
        ActiveValidation::OrmPlugins.send :remove_const, :FakePlugin
        config.orm_adapters_registry.delete "fake"
        config.orm_adapter = adapter
      end

      after do
      end

      it "setup correctly loaded adapter" do
        config.orm_adapter = "fake"
        expect(config.orm_adapter.to_s).to eq "fake_plugin"
      end
    end

    it "raise if plugin not found" do
      expect { config.orm_adapter = "not_exist" }.to raise_error LoadError
    end
  end
end
