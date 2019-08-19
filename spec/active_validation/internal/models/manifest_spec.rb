# frozen_string_literal: true

describe ActiveValidation::Internal::Models::Manifest do
  subject { described_class.new version: 1, base_klass: "Foo" }

  before { define_const "Foo" }

  let(:check_validates) do
    ActiveValidation::Internal::Models::Check.new method_name: "validates",
                                                  argument:    "name",
                                                  options:     { presence: true }
  end
  let(:check_validate) do
    ActiveValidation::Internal::Models::Check.new method_name: "validate", argument: "my_method"
  end

  let(:check_validates_with) do
    define_const("MyValidator", superclass: ActiveModel::Validator) do
      def initialize(*); end

      def validate(*); end
    end
    ActiveValidation::Internal::Models::Check.new method_name: "validates_with", argument: "MyValidator"
  end

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
      it("should have '#{attr}' attribute") { expect(subject.as_json).to have_key attr }
    end

    it "works correctly with out 'only' option" do
      expect(subject.as_json).to eq subject.to_hash
    end

    it "produce right output with 'only' option base_klass" do
      expect(subject.as_json(only: [:base_klass])).to eq(base_klass: "Foo")
    end

    context "with checks" do
      subject { described_class.new version: 1, base_klass: "Foo", checks: [check1, check2] }

      let(:check1) { ActiveValidation::Internal::Models::Check.new(method_name: "validates", argument: "check1") }
      let(:check2) { ActiveValidation::Internal::Models::Check.new(method_name: "validate", argument: "check2") }

      it "with out options" do
        hash = { version:    1,
                 base_klass: "Foo",
                 checks:     [{ method_name: "validates", argument: "check1", options: {} },
                              { method_name: "validate", argument: "check2", options: {} }],
                 name:       nil,
                 id:         nil }
        expect(subject.as_json).to eq hash
      end

      it "with options for manifest" do
        hash = { version: 1,
                 checks:  [{ method_name: "validates", argument: "check1", options: {} },
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
                 checks_attributes: [{ method_name: "validates", argument: "check1", options: {} },
                                     { method_name: "validate", argument: "check2", options: {} }],
                 name:              nil,
                 id:                nil }
        expect(subject.as_json(checks: { as: :checks_attributes })).to eq hash
      end
    end
  end

  context "#install" do
    subject { described_class.new version: 1, base_klass: "Bar" }

    let(:callbacks) { Bar.__callbacks[:validate].send(:chain) }

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
end
