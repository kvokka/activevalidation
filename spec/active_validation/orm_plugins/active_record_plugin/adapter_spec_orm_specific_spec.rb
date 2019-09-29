# frozen_string_literal: true

describe ActiveValidation::OrmPlugins::ActiveRecordPlugin::Adapter, type: :active_record do
  let(:manifest) { ActiveValidation::Internal::Models::Manifest.new version: 1, base_klass: "Foo", name: "subject" }
  let(:check_validates) do
    ActiveValidation::Internal::Models::Check.new method_name: "validates",
                                                  argument:    "name",
                                                  options:     { presence: true }
  end
  let(:check_validate) do
    ActiveValidation::Internal::Models::Check.new method_name: "validate", argument: "my_method"
  end

  let(:check_validates_with) do
    define_const "MyValidator", superclass: ActiveModel::Validator
    ActiveValidation::Internal::Models::Check.new method_name: "validates_with", argument: "MyValidator"
  end

  it "has right plugin name" do
    expect(described_class.plugin_name).to eq "active_record_plugin"
  end

  it "has right adapter name" do
    expect(described_class.adapter_name).to eq "active_record"
  end

  context "#add_manifest" do
    it "Add manifest with out checks" do
      expect(subject.add_manifest(manifest)).to eq manifest
      expect(ActiveValidation::Manifest.count).to eq 1
    end

    it "Add manifest with checks" do
      manifest.checks << check_validate
      manifest.checks << check_validates
      manifest.checks << check_validates_with
      expect(subject.add_manifest(manifest)).to eq manifest
      expect(ActiveValidation::Manifest.count).to eq 1
      expect(ActiveValidation::Check.count).to eq 3
    end
  end

  context "search" do
    let!(:ar_manifest1) { create :manifest }
    let!(:ar_manifest2) { create :manifest, name: "subject" }
    let!(:ar_manifest3) { create :manifest }
    let!(:ar_manifest4) { create :manifest, version: 2 }

    context "#find_manifest" do
      it "find correct manifest" do
        expect(subject.find_manifest(name: "subject")).to eq ar_manifest2
      end

      it "find correct manifest with checks" do
        create :check_validates, manifest: ar_manifest2
        create :check_validate, manifest: ar_manifest2, argument: "my_method"
        manifest.checks << check_validates
        manifest.checks << check_validate
        expect(subject.find_manifest(name: "subject")).to eq manifest
      end

      it "raise NotFound error id nothing found" do
        expect { subject.find_manifest(name: "not_exist") }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context "#find_manifests" do
      let!(:ar_manifest5) { create :manifest, base_klass: "Bar" }
      let(:json_options) { { include: { checks: { methods: %i[method_name] } }, root: false } }

      it "find correct manifests" do
        result = [ar_manifest1, ar_manifest2, ar_manifest3].map do |record|
          ActiveValidation::Internal::Models::Manifest.new record.as_json(json_options).to_options!
        end
        expect(subject.find_manifests(version: 1, base_klass: "Foo")).to match_array result
      end

      it "return array with 1 element if only 1 record found" do
        result = ActiveValidation::Internal::Models::Manifest.new ar_manifest5.as_json(json_options).to_options!
        expect(subject.find_manifests(base_klass: "Bar")).to match_array result
      end
    end
  end
end
