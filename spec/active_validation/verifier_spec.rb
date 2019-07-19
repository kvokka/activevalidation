# frozen_string_literal: true

describe ActiveValidation::Verifier do
  let(:model) { define_const "Foo" }

  context "::registry" do
    it "return the global registry for verifier" do
      expect(described_class.registry).to eq ActiveValidation.config.verifiers_registry
    end
  end

  context "with fake registry" do
    subject { described_class.find_or_build model }

    let(:registry) do
      ActiveValidation::Decorators::DisallowsDuplicatesRegistry.new(ActiveValidation::Registry.new("Dummy"))
    end

    before { allow(described_class).to receive(:registry).and_return(registry) }

    %i[versions add_manifest find_manifest find_manifests].each do |m|
      it { is_expected.to delegate(m).to(:proxy) }
    end

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
        described_class.find_or_build(model) { |v| v.as_hash_with_indifferent_access = true }
        expect(registry.find(model).as_hash_with_indifferent_access).to be_truthy
        described_class.find_or_build(model) { |v| v.version = :V301 }
        described_class.find_or_build(model) { |v| v.as_hash_with_indifferent_access = false }
        expect(registry.find(model).version).to eq ActiveValidation::Values::Version.new(301)
        expect(registry.find(model).as_hash_with_indifferent_access).to be_falsey
      end
    end

    context "#version" do
      before do
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

    context "with manifests" do
      let!(:manifest1) { create(:manifest, base_klass: model.name) }
      let!(:manifest2) { create(:manifest, base_klass: model.name) }
      let!(:manifest3) { create(:manifest, base_klass: model.name) }

      context "#lock_manifest" do
        it "locks manifest in with manifest2 as with_indifferent_access" do
          subject = described_class.new(model) { |k| k.manifest = manifest2 }
          expect(subject.manifest).to eq manifest2.with_indifferent_access
        end

        it "locks manifest in with manifest2 hash as as_hash_with_indifferent_access" do
          subject = described_class.new(model) { |k| k.manifest = manifest2.with_indifferent_access }
          expect(subject.manifest).to eq manifest2.with_indifferent_access
        end
      end

      context "#current_manifest" do
        it "return manifest if it is set" do
          subject = described_class.new(model) { |k| k.manifest = manifest2 }
          expect(subject.current_manifest).to eq manifest2.with_indifferent_access
        end

        it "return the latest manifest if manifest is not set" do
          expect(subject.current_manifest).to eq manifest3.with_indifferent_access
        end

        it "return right manifest if version bumped" do
          last = create(:manifest, base_klass: model.name, version: 3)
          create(:manifest, base_klass: model.name, version: 2)

          expect(subject.current_manifest).to eq last.with_indifferent_access
        end
      end
    end

    context "#descendants_with_active_validation" do
      subject { described_class.find_or_build(foo_descendant3).descendants_with_active_validation }

      let!(:should_not_be_in_the_list) { define_const "ShouldNotBeInTheList" }
      let!(:bar) { define_const "Bar", superclass: should_not_be_in_the_list, with_active_validation: true }

      let(:foo) { define_const "Foo", superclass: should_not_be_in_the_list, with_active_validation: true }
      let(:foo_descendant1) { define_const "FooDescendant1", superclass: foo }
      let(:foo_descendant2) { define_const "FooDescendant2", superclass: foo_descendant1 }
      let(:foo_descendant3) { define_const "FooDescendant3", superclass: foo_descendant2 }

      it "returns only Foo based constants" do
        expect(subject).to match [foo_descendant2, foo_descendant1, foo]
      end

      it "returns empty array for foo" do
        expect(described_class.find_or_build(foo).descendants_with_active_validation).to be_empty
      end
    end

    context "#setup_validations" do
      let!(:model) { define_const("Foo") { def foo_allowed; end } }

      before do
        create :manifest, :validate
        create :manifest, :validates_with
        create :manifest, :validates

        model.include ActiveModel::Validations
        described_class.find_or_build("Foo").setup_validations
      end

      it "setups default factories validations to default model" do
        expect(model.validators).to all be_a ActiveModel::Validations::PresenceValidator
      end

      it "setups default factories callbacks to default model" do
        callbacks = model.__callbacks[:validate].send(:chain).map(&:filter)
        expect(callbacks).to all be_a ActiveModel::Validations::PresenceValidator
      end
    end
  end
end
