# frozen_string_literal: true

describe ActiveValidation::Verifier do
  let(:model) { define_const "Foo" }
  let(:registry) { described_class.registry }

  context "simple examples" do
    subject do
      described_class.new(model) { |k| k.instance_variable_set :@bar, :setted }
    end

    it "setups base klass" do
      expect(subject.base_klass).to eq model
    end

    it "yield provided block" do
      expect(subject.instance_variable_get(:@bar)).to eq :setted
    end

    it "includes current ORM adapter my default" do
      expect(subject.orm_adapter.adapter_name).to eq ENV["ORM"]
    end
  end

  context "with restored configuration" do
    subject { described_class.new(model) }

    around do |example|
      backup = ActiveValidation.config.verifier_defaults
      example.call
      ActiveValidation.config.verifier_defaults(&backup)
      registry.clear
    end

    it "setups defaults from configuration" do
      ActiveValidation.config.verifier_defaults { |k| k.instance_variable_set(:@test, :passed) }
      expect(subject.instance_variable_get(:@test)).to eq :passed
    end

    it "add self to manifests registry" do
      subject
      expect(registry.find(model)).to eq subject
    end
  end

  context "::registry" do
    it "return the global registry for verifier" do
      expect(registry).to eq ActiveValidation.config.verifiers_registry
    end
  end

  context "::find_or_build" do
    before do
      define_const "#{model.name}::Validations::V300", "#{model.name}::Validations::V301"
    end

    it "build new instance if it was not declared" do
      expect(registry).not_to be_registered(model)
      described_class.find_or_build(model)
      expect(registry).to be_registered(model)
    end

    it "execute the block after build for new verifier" do
      expect(registry).not_to be_registered(model)
      described_class.find_or_build(model) { |v| v.api_version = :V300 }
      expect(registry.find(model).api_version).to eq ActiveValidation::Values::ApiVersion.new(300)
    end

    it "execute the block after build for existed verifier" do
      expect(registry).not_to be_registered(model)
      described_class.new(model) { |v| v.api_version = :V300 }
      described_class.find_or_build(model) { |v| v.api_version = :V301 }
      expect(registry.find(model).api_version).to eq ActiveValidation::Values::ApiVersion.new(301)
    end
  end

  context "#api_version" do
    subject { described_class.new(model) }

    before  do
      define_const "#{model.name}::Validations::V300",
                   "#{model.name}::Validations::V301",
                   "#{model.name}::Validations::V302"
    end

    it "use latest version by default" do
      expect(subject.api_version).to eq ActiveValidation::Values::ApiVersion.new(302)
    end

    it "set/gets api_version" do
      subject.api_version = :V300
      expect(subject.api_version).to eq ActiveValidation::Values::ApiVersion.new(300)
    end
  end

  context "#api_versions" do
    before do
      define_const "Bar", superclass: ActiveRecord::Base do
        active_validation
      end

      define_const "Bar::Validations::V1",
                   "Bar::Validations::V2",
                   "Bar::Validations::V23",
                   "Bar::Validations::V42"
    end

    it "returns correct versions in asc order" do
      expect(described_class.find_or_build(Bar).api_versions.map(&:to_i)).to eq [1, 2, 23, 42]
    end
  end
end
