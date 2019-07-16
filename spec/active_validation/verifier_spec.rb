# frozen_string_literal: true

describe ActiveValidation::Verifier do
  let(:model) { define_const "Foo" }

  context "::registry" do
    it "return the global registry for verifier" do
      expect(described_class.registry).to eq ActiveValidation.config.verifiers_registry
    end
  end

  context "with fake registry" do
    let(:registry) do
      ActiveValidation::Decorators::DisallowsDuplicatesRegistry.new(ActiveValidation::Registry.new("Dummy"))
    end

    before { allow(described_class).to receive(:registry).and_return(registry) }

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

    context "::find_or_build" do
      before do
        define_consts "#{model.name}::Validations::V300", "#{model.name}::Validations::V301"
      end

      it "build new instance if it was not declared" do
        expect(registry).not_to be_registered(model)
        described_class.find_or_build(model)
        expect(registry).to be_registered(model)
      end

      it "execute the block after build for new verifier" do
        expect(registry).not_to be_registered(model)
        described_class.find_or_build(model) { |v| v.version = :V300 }
        expect(registry.find(model).version).to eq ActiveValidation::Values::Version.new(300)
      end

      it "execute the block after build for existed verifier" do
        expect(registry).not_to be_registered(model)
        described_class.new(model) { |v| v.version = :V300 }
        described_class.find_or_build(model) { |v| v.version = :V301 }
        described_class.find_or_build(model) { |v| v.as_hash_with_indifferent_access = false }
        expect(registry.find(model).version).to eq ActiveValidation::Values::Version.new(301)
        expect(registry.find(model).as_hash_with_indifferent_access).to be_falsey
      end
    end

    context "#version" do
      subject { described_class.new(model) }

      before  do
        define_consts "#{model.name}::Validations::V300",
                      "#{model.name}::Validations::V301",
                      "#{model.name}::Validations::V302"
      end

      it "use latest version by default" do
        expect(subject.version).to eq ActiveValidation::Values::Version.new(302)
      end

      it "set/gets version" do
        subject.version = :V300
        expect(subject.version).to eq ActiveValidation::Values::Version.new(300)
      end
    end

    context "#base_class" do
      it "return Class if base_klass as String given" do
        expect(described_class.new(model.name).base_class).to eq model
      end

      it "return Class if base_klass as Class given" do
        expect(described_class.new(model).base_class).to eq model
      end
    end
  end
end
