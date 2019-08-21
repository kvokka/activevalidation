# frozen_string_literal: true

describe ActiveValidation::Internal::Models::Manifest::Installer do
  subject { described_class.new base_class: Bar, context: context }

  let(:check_validate)       { build :internal_check_validate       }
  let(:check_validates)      { build :internal_check_validates      }
  let(:check_validates_with) { build :internal_check_validates_with }

  let(:callbacks) { Bar._validate_callbacks.send(:chain) }
  let(:context)   { "active_validation_1" }

  before do
    define_const("Bar") { include ActiveModel::Validations }
  end

  %i[base_class installed_callbacks checks context].each do |m|
    it { is_expected.to have_attr_reader m }
  end

  context "#install" do
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

      it("does not contain any validators") { expect(Bar.validators).to be_empty }
    end

    context "does not affect checks from another installer on another class" do
      let(:installer2) { described_class.new context: context, base_class: Baz }

      before do
        define_const("Baz") { include ActiveModel::Validations }
        installer2.checks << check_validate2 << check_validates2 << check_validates_with2
        installer2.install
        subject.uninstall
      end

      it("does not have any callback chain") { expect(callbacks).to be_empty }

      it("does not affect installer2 checks") { expect(installer2.callbacks_chain.count).to eq 3 }
    end

    context "does not other affect native checks on the base class" do
      before do
        subject.base_class.public_send(*check_validate2.to_validation_arguments)
        subject.base_class.public_send(*check_validates_with2.to_validation_arguments)
        subject.uninstall
      end

      it("has 3 callbacks in the chain") { expect(callbacks.count).to eq 2 }

      it("have correct validator") { expect(Bar.validators).to all(be_a_kind_of(MyValidator2)) }
      it("has only one validator") { expect(Bar.validators.size).to eq 1 }
    end
  end
end
