# frozen_string_literal: true

describe ActiveValidation::VerifierProxy do
  subject { described_class.new ActiveValidation::Verifier.find_or_build "Bar" }

  include_examples "verifiers registry"

  %i[base_klass version orm_adapter manifest_name_formatter as_hash_with_indifferent_access].each do |m|
    it { is_expected.to delegate(m).to(:verifier) }
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
  end

  context "Manifest" do
    let(:bar) { define_const("Bar", with_active_validation: true) }

    before do
      allow(ActiveValidation::Verifier).to receive(:registry).and_return(registry)

      define_const "Bar::Validations::V1"
      define_const "Bar::Validations::V42"
    end

    context "#add_manifest" do
      let(:checks) { [build(:check_validates).with_indifferent_access] }

      include_examples "manifest attributes check"

      it do
        expect(subject.add_manifest).to include(name:       a_kind_of(String),
                                                base_klass: a_kind_of(String),
                                                version:    a_kind_of(ActiveValidation::Values::Version))
      end

      it "returns right class" do
        expect(subject.add_manifest(checks: checks)).to be_a ActiveSupport::HashWithIndifferentAccess
      end

      it "contain checks array with out checks" do
        expect(subject.add_manifest).to have_key "checks"
      end

      it "contain checks array with checks" do
        expect(subject.add_manifest(checks: checks)).to have_key "checks"
        expect(subject.find_manifest(base_klass: "Bar").fetch(:checks).size).to eq 1
      end

      it "accept checks with simplified type" do
        checks = [{ method_name: "validates", argument: "name", options: { presence: true } }]
        expect(subject.add_manifest(checks: checks)).to have_key "checks"
      end
    end

    context "#find_manifest" do
      let!(:manifest) { create :manifest, base_klass: bar, version: 42 }

      include_examples "manifest attributes check"

      it do
        expect(subject.find_manifest).to include(name:       a_kind_of(String),
                                                 base_klass: a_kind_of(String),
                                                 version:    a_kind_of(ActiveValidation::Values::Version))
      end

      it "find existed Manifest" do
        expect(subject.find_manifest(base_klass: "Bar")).to eq manifest.with_indifferent_access
      end

      it "find existed Manifest if base_klass is Class" do
        expect(subject.find_manifest(base_klass: Bar)).to eq manifest.with_indifferent_access
      end

      it "returns version value object" do
        expect(subject.find_manifest(base_klass: "Bar").fetch("version")).to eq 42
      end

      context "with pre-defined data" do
        let(:not_exist) { subject.find_manifest(base_klass: "Bar", version: 23) }

        before do
          1.upto(5) { |n| create :manifest, base_klass: bar, version: n, name: "Bar#{n}" }
        end

        it "find correct manifest by version" do
          expect(subject.find_manifest(base_klass: "Bar", version: 3).fetch("name")).to eq "Bar3"
        end

        it "find latest manifest" do
          expect(subject.find_manifest(base_klass: "Bar").fetch("name")).to eq "Bar5"
        end

        it "find nothing and return HashWithIndifferentAccess" do
          expect { not_exist }.to raise_error ActiveValidation::Errors::NotFoundError
        end
      end
    end

    context "#find_manifests" do
      let!(:bar_manifest1)   { create :manifest, base_klass: bar, version: 1 }
      let!(:bar_manifest42)  { create :manifest, base_klass: bar, version: 42 }
      let!(:foo_manifest13)  { create :manifest, base_klass: foo, version: 13 }

      let(:foo) { define_const("Foo", with_active_validation: true) }

      include_examples "manifest attributes check"

      it "returns filtered results" do
        result = [bar_manifest42.with_indifferent_access, bar_manifest1.with_indifferent_access]
        expect(subject.find_manifests).to eq result
        expect(subject.find_manifests(base_klass: "Bar")).to eq result
      end

      it "find nothing and return HashWithIndifferentAccess" do
        expect { subject.find_manifest(version: 123) }.to raise_error ActiveValidation::Errors::NotFoundError
      end

      it "return array if 1 element" do
        create :manifest, base_klass: bar, version: 55
        result = [bar_manifest42.with_indifferent_access]
        expect(subject.find_manifests(base_klass: "Bar", version: 42)).to eq result
      end
    end

    context "private #normalize_records" do
      it "return correct error class" do
        msg = "The object 42 with class Integer must respond_to method #with_indifferent_access"
        expect { subject.send(:normalize_records, 42) }.to raise_error(ActiveValidation::Errors::MustRespondTo, msg)
      end
    end
  end
end
