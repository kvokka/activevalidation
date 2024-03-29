# frozen_string_literal: true

describe ActiveValidation::Verifier do
  subject { described_class.find_or_build "Foo" }

  let(:model) { define_const("Foo") { attr_reader :manifest } }

  context "class methods" do
    subject { described_class }

    it "return the global registry for verifier" do
      expect(subject.registry).to eq ActiveValidation.config.verifiers_registry
    end

    it { is_expected.to delegate(:find_or_build).to(:registry) }
  end

  %i[failed_attempt_retry_time
     enabled
     observer
     validations_module_name
     base_klass
     orm_adapter
     manifest_name_formatter
     manifest].each { |m| it { is_expected.to have_attr_reader m } }

  it { is_expected.to delegate(:install).to(:observer) }

  context "with fake registry" do
    subject { described_class.find_or_build "Bar" }

    let!(:bar) do
      define_const "Bar" do
        include ActiveValidation::ModelExtensionBase
        active_validation
      end
    end

    include_examples "verifiers registry"

    context "orm methods" do
      context "#add_manifest" do
        before do
          allow(subject.orm_adapter).to receive(:add_manifest)
          define_const "Bar::Validations::V17"
        end

        it "calculate name and set default klass & version" do
          subject.add_manifest
          defaults = { base_klass: bar.to_s,
                       version:    ActiveValidation::Values::Version.new(17),
                       name:       "Manifest for Bar" }
          expect(subject.orm_adapter).to have_received(:add_manifest).with(defaults)
        end
      end

      context "#find_manifest" do
        before { allow(subject.orm_adapter).to receive(:find_manifest) }

        it "set defaults" do
          subject.find_manifest
          defaults = { base_klass: bar.to_s }
          expect(subject.orm_adapter).to have_received(:find_manifest).with(defaults)
        end
      end

      context "#find_manifests" do
        before { allow(subject.orm_adapter).to receive(:find_manifests) }

        it "set defaults" do
          subject.find_manifests
          defaults = { base_klass: bar.to_s }
          expect(subject.orm_adapter).to have_received(:find_manifests).with(defaults)
        end
      end
    end

    context "#versions" do
      before do
        define_consts "Bar::Validations::V1",
                      "Bar::Validations::V2",
                      "Bar::Validations::V23",
                      "Bar::Validations::V42"
      end

      it "returns correct versions in asc order" do
        expect(subject.versions.map(&:to_i)).to eq [1, 2, 23, 42]
      end

      it "returns only value version type" do
        expect(subject.versions).to all be_an ActiveValidation::Values::Version
      end
    end

    context "#version" do
      before do
        define_consts "Bar::Validations::V300",
                      "Bar::Validations::V301",
                      "Bar::Validations::V302"
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

    context "#descendants_with_active_validation" do
      subject { described_class.find_or_build(foo_descendant3).descendants_with_active_validation }

      let!(:should_not_be_in_the_list) { define_const "ShouldNotBeInTheList" }
      let!(:baz) do
        define_const("Baz", superclass: should_not_be_in_the_list) do
          include ActiveValidation::ModelExtensionBase
          active_validation
        end
      end

      let(:foo) do
        define_const("Foo", superclass: should_not_be_in_the_list) do
          include ActiveValidation::ModelExtensionBase
          active_validation
          attr_reader :manifest
        end
      end

      let(:foo_descendant1) { define_const("FooDescendant1", superclass: foo) { attr_reader :manifest } }
      let(:foo_descendant2) { define_const("FooDescendant2", superclass: foo_descendant1) { attr_reader :manifest } }
      let(:foo_descendant3) { define_const("FooDescendant3", superclass: foo_descendant2) }

      it "returns only Foo based constants" do
        expect(subject).to match [foo_descendant2, foo_descendant1, foo]
      end

      it "returns empty array for foo" do
        expect(described_class.find_or_build(foo).descendants_with_active_validation).to be_empty
      end
    end

    context "#current_manifest" do
      let(:manifest) { ActiveValidation::Internal::Models::Manifest.new version: 1, base_klass: "Bar" }

      it "return manifest, if it was set" do
        subject.manifest = manifest
        expect(subject.current_manifest).to eq manifest
      end

      it "call #find_manifests if manifest is not set" do
        allow(subject).to receive(:find_manifests).and_return([]) # rubocop:disable RSpec/SubjectStub
        define_consts "Bar::Validations::V11"
        expect(subject.current_manifest).to be_nil
        expect(subject).to have_received(:find_manifests)
      end
    end

    context "#initialize" do
      it "yield given block" do
        expect { |b| described_class.find_or_build(bar.name, &b) }.to yield_control
      end

      it "register self in global registry" do
        subject
        expect(registry).to be_registered(bar.to_s)
      end

      it "invoke default config" do
        allow(ActiveValidation.config.verifier_defaults).to receive(:call)
        expect(ActiveValidation.config.verifier_defaults).to have_received(:call).with(subject)
      end
    end
  end

  context "#enabled" do
    context "true" do
      subject { described_class.find_or_build("Foo") { |c| c.enabled = true }.enabled? }

      it { is_expected.to be true }
    end

    context "false" do
      subject { described_class.find_or_build("Foo") { |c| c.enabled = false }.enabled? }

      it { is_expected.to be false }
    end
  end

  context "#install!" do
    let!(:bar) { define_const("Bar", superclass: model) { attr_reader :manifest } }

    before do
      model.include ActiveValidation::ModelExtensionBase
      allow(Foo.active_validation).to receive(:install)
      allow(Bar.active_validation).to receive(:install)
      described_class.find_or_build("Bar").install!
    end

    it("installs on Foo") { expect(Foo.active_validation).to have_received(:install) }
    it("installs on Bar") { expect(Bar.active_validation).to have_received(:install) }
  end
end
