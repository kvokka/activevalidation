# frozen_string_literal: true

describe ActiveValidation::Verifier do
  subject { described_class.find_or_build "Foo" }

  let(:model) { define_const "Foo" }

  context "class methods" do
    subject { described_class }

    it "return the global registry for verifier" do
      expect(subject.registry).to eq ActiveValidation.config.verifiers_registry
    end

    it { is_expected.to delegate(:find_or_build).to(:registry) }
  end

  %i[validations_module_name base_klass orm_adapter manifest_name_formatter manifest].each do |m|
    it { is_expected.to have_attr_reader m }
  end

  context "with fake registry" do
    subject { described_class.find_or_build "Bar" }

    let!(:bar) { define_const "Bar", with_active_validation: true }

    include_examples "verifiers registry"

    context "orm methods" do
      context "#add_manifest" do
        before do
          allow(subject.orm_adapter).to receive(:add_manifest)
          define_const "Bar::Validations::V17"
        end

        it "set defaults" do
          subject.add_manifest
          defaults = { base_klass: bar.to_s, version: ActiveValidation::Values::Version.new(17) }
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
        define_const "Bar", with_active_validation: true

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

    context "#current_manifest" do
      let(:manifest) { ActiveValidation::Internal::Models::Manifest.new version: 1, base_klass: "Bar" }

      it "return manifest, if it was set" do
        subject.manifest = manifest
        expect(subject.current_manifest).to eq manifest
      end

      it "call #find_manifest if manifest is not set" do
        allow(subject).to receive(:find_manifest) # rubocop:disable RSpec/SubjectStub
        define_consts "Bar::Validations::V11"
        subject.current_manifest
        expect(subject).to have_received(:find_manifest).with(version: 11)
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
end
