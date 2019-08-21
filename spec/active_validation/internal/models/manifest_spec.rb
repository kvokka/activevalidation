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

  context "installation" do
    before do
      allow(ActiveValidation::Internal::Models::Manifest::Installer).to receive(:new).and_return(installer)
    end

    let(:installer) do
      instance_double ActiveValidation::Internal::Models::Manifest::Installer, uninstall: false, install: true
    end

    context "install" do
      before { subject.install }

      it("installs once installed") do
        subject.install
        expect(installer).to have_received(:install).once
      end

      it { expect(subject).to be_installed }
    end

    context "uninstall" do
      before do
        subject.install
        subject.uninstall
      end

      it("uninstalls once when installed") do
        subject.uninstall
        expect(installer).to have_received(:uninstall).once
      end

      it { expect(subject).not_to be_installed }
    end
  end
end
