# frozen_string_literal: true

describe ActiveValidation::Internal::Models::Manifest do
  subject { described_class.new version: 1, base_klass: "Foo" }

  before { define_const "Foo" }

  let(:check_validate)       { build :internal_check_validate       }
  let(:check_validates)      { build :internal_check_validates      }
  let(:check_validates_with) { build :internal_check_validates_with }

  %i[version base_klass created_at checks options other id name].each do |m|
    it { is_expected.to have_attr_reader m }
  end

  context "#class_name" do
    it "converts the method name to value object" do
      expect(subject.base_class).to eq Foo
    end
  end

  context "equality check" do
    it "if id is equal" do
      common = { version: 1, base_klass: "Foo", id: 42 }
      manifest1 = described_class.new common
      manifest2 = described_class.new common
      expect(manifest1).to eq manifest2
    end

    it "if attributes is equal, if even id are not" do
      common = { version: 1, base_klass: "Foo", checks: [], options: { bar: :baz } }
      manifest1 = described_class.new common.merge id: 1
      manifest2 = described_class.new common.merge id: 2
      expect(manifest1).to eq manifest2
    end
  end

  context "#to_hash" do
    it "converts to Hash with out coercion" do
      expect { Hash(subject) }.not_to raise_error
    end
  end

  context "#as_json" do
    %i[version base_klass checks name id].each do |attr|
      it("has '#{attr}' attribute") { expect(subject.as_json).to have_key attr }
    end

    it "works correctly with out 'only' option" do
      expect(subject.as_json).to eq subject.to_hash
    end

    it "produce right output with 'only' option base_klass" do
      expect(subject.as_json(only: [:base_klass])).to eq(base_klass: "Foo")
    end

    context "with checks" do
      subject { described_class.new version: 1, base_klass: "Foo", checks: [check1, check2] }

      let(:check1) { build :internal_check_validates, argument: "check1" }
      let(:check2) { build :internal_check_validate,  argument: "check2" }

      it "with out options" do
        hash = { version:    1,
                 base_klass: "Foo",
                 checks:     [{ method_name: "validates", argument: "check1", options: { "presence" => true } },
                              { method_name: "validate", argument: "check2", options: {} }],
                 name:       nil,
                 id:         nil }
        expect(subject.as_json).to eq hash
      end

      it "with options for manifest" do
        hash = { version: 1,
                 checks:  [{ method_name: "validates", argument: "check1", options: { "presence" => true } },
                           { method_name: "validate", argument: "check2", options: {} }] }
        expect(subject.as_json(only: %i[checks version])).to eq hash
      end

      it "with options for checks" do
        hash = { version:    1,
                 base_klass: "Foo",
                 checks:     [{ argument: "check1" },
                              { argument: "check2" }],
                 name:       nil,
                 id:         nil }
        expect(subject.as_json(checks: { only: [:argument] })).to eq hash
      end

      it "with renamed checks" do
        hash = { version:           1,
                 base_klass:        "Foo",
                 checks_attributes: [{ method_name: "validates", argument: "check1", options: { "presence" => true } },
                                     { method_name: "validate", argument: "check2", options: {} }],
                 name:              nil,
                 id:                nil }
        expect(subject.as_json(checks: { as: :checks_attributes })).to eq hash
      end
    end
  end

  context "#install" do
    subject { described_class.new version: 1, base_klass: "Bar" }

    let(:callbacks) { Bar._validate_callbacks.send(:chain) }

    before do
      define_const("Bar") { include ActiveModel::Validations }
    end

    context "with 3 validations" do
      before do
        subject.checks << check_validate << check_validates << check_validates_with
        subject.install
      end

      it "setup validations to base_klass" do
        expect(Bar.validators).to include a_kind_of ActiveModel::Validations::PresenceValidator
        expect(Bar.validators).to include a_kind_of MyValidator
        expect(Bar.validators.size).to eq 2
      end

      it "setups default factories callbacks to default model" do
        expect(callbacks.size).to eq 3
      end

      it("is installed") { expect(subject).to be_installed }

      it "setups installed callbacks to default model" do
        expect(subject.installed_callbacks.size).to eq 3
      end
    end

    context "validations should be in the right context" do
      let(:callback) { callbacks.last }
      let(:bar) { Bar.new }

      shared_examples "check with context" do
        it "does not execute with out the context" do
          bar.valid?
          expect(validator).not_to have_received(:validate)
        end

        it "executes with the context" do
          bar.valid?(subject.context)
          expect(validator).to have_received(:validate)
        end
      end

      context "validates_with" do
        let(:validator) { instance_double MyValidator }

        before do
          subject.checks << check_validates_with
          allow(MyValidator).to receive(:new).and_return(validator)
          allow(validator).to receive(:validate)
          subject.install
        end

        include_examples "check with context"
      end

      context "validates" do
        let(:validator) { instance_double ActiveModel::Validations::PresenceValidator }

        before do
          subject.checks << check_validates
          allow(ActiveModel::Validations::PresenceValidator).to receive(:new).and_return(validator)
          allow(validator).to receive(:validate)
          subject.install
        end

        include_examples "check with context"
      end

      context "validate" do
        before do
          define_const("Bar") do
            include ActiveModel::Validations
            def my_method; end
          end

          subject.checks << check_validate
          allow(Bar).to receive(:new).and_return(bar)
          allow(bar).to receive(:my_method)
          subject.install
        end

        it "does not execute with out the context" do
          bar.valid?
          expect(bar).not_to have_received(:my_method)
        end

        it "executes with the context" do
          bar.valid?(subject.context)
          expect(bar).to have_received(:my_method)
        end
      end
    end
  end

  context "#uninstall" do
    subject { described_class.new version: 1, base_klass: "Bar" }

    let(:callbacks) { Bar._validate_callbacks.send(:chain) }

    let(:check_validate2)       { build :internal_check_validate       }
    let(:check_validates2)      { build :internal_check_validates      }
    let(:check_validates_with2) { build :internal_check_validates_with, argument: "MyValidator2" }

    before do
      define_const("Bar") { include ActiveModel::Validations }
      subject.checks << check_validate << check_validates << check_validates_with
      subject.install
    end

    context "should correctly remove all checks" do
      before { subject.uninstall }

      it("does not have any callback chain") { expect(callbacks).to be_empty }
      it("does not ne installed") { expect(subject).not_to be_installed }

      it("does not contain any validators") { expect(Bar.validators).to be_empty }
    end

    context "does not affect checks from another manifest on another class" do
      let(:manifest2) { described_class.new version: 1, base_klass: "Baz" }

      before do
        define_const("Baz") { include ActiveModel::Validations }
        manifest2.checks << check_validate2 << check_validates2 << check_validates_with2
        manifest2.install
        subject.uninstall
      end

      it("does not have any callback chain") { expect(callbacks).to be_empty }
      it("does not ne installed") { expect(subject).not_to be_installed }

      it("does not affect manifest2 checks") { expect(manifest2.send(:callbacks_chain).count).to eq 3 }
    end

    context "does not other affect native checks on the base class" do
      before do
        subject.base_class.public_send(*check_validate2.to_validation_arguments)
        subject.base_class.public_send(*check_validates_with2.to_validation_arguments)
        subject.uninstall
      end

      it("has 3 callbacks in the chain") { expect(callbacks.count).to eq 2 }
      it("does not be installed") { expect(subject).not_to be_installed }

      it("have correct validator") { expect(Bar.validators).to all(be_a_kind_of(MyValidator2)) }
      it("has only one validator") { expect(Bar.validators.size).to eq 1 }
    end
  end
end
