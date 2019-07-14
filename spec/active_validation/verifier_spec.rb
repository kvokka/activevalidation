# frozen_string_literal: true

describe ActiveValidation::Verifier do
  let(:model) { define_const "Foo" }
  let(:registry) { ActiveValidation::Decorators::DisallowsDuplicatesRegistry.new(described_class.registry) }

  before { registry.clear }

  after { registry.clear }

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
      registry.clear
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

  context "::registry" do
    it "return the global registry for verifier" do
      expect(registry).to eq ActiveValidation.config.verifiers_registry
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

  context "#versions" do
    before do
      define_const "Bar", with_active_validation: true

      define_consts "Bar::Validations::V1",
                    "Bar::Validations::V2",
                    "Bar::Validations::V23",
                    "Bar::Validations::V42"
    end

    it "returns correct versions in asc order" do
      expect(described_class.find_or_build(Bar).versions.map(&:to_i)).to eq [1, 2, 23, 42]
    end
  end

  context "Manifest" do
    subject { described_class.find_or_build(bar) }

    let(:bar) { define_const("Bar", with_active_validation: true) }

    before do
      subject
      define_const "Bar::Validations::V1"
      define_const "Bar::Validations::V42"
    end

    context "#add_manifest" do
      let(:checks) { [attributes_for(:check_validates)] }

      it do
        expect(subject.add_manifest).to include(name:       a_kind_of(String),
                                                base_klass: a_kind_of(String),
                                                version:    a_kind_of(ActiveValidation::Values::Version))
      end

      it "raises no error" do
        expect { subject.add_manifest(checks_attributes: checks) }.not_to raise_error
      end

      it "returns right class" do
        expect(subject.add_manifest(checks_attributes: checks)).to be_a ActiveSupport::HashWithIndifferentAccess
      end

      it "contain checks array with out checks" do
        expect(subject.add_manifest).to have_key "checks"
      end

      it "contain checks array with checks" do
        expect(subject.add_manifest(checks_attributes: checks)).to have_key "checks"
      end
    end

    context "#find_manifest" do
      let!(:manifest) { create :manifest, base_klass: bar, version: 42 }

      it do
        expect(subject.find_manifest).to include(name:       a_kind_of(String),
                                                 base_klass: a_kind_of(String),
                                                 version:    a_kind_of(ActiveValidation::Values::Version))
      end

      it "find existed Manifest" do
        expect(subject.find_manifest(base_klass: "Bar")).to eq manifest.as_hash_with_indifferent_access
      end

      it "find existed Manifest if base_klass is Class" do
        expect(subject.find_manifest(base_klass: Bar)).to eq manifest.as_hash_with_indifferent_access
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
          expect(not_exist).to eq ActiveSupport::HashWithIndifferentAccess.new
        end
      end
    end

    context "#find_manifests" do
      let!(:bar_manifest1)   { create :manifest, base_klass: bar, version: 1 }
      let!(:bar_manifest42)  { create :manifest, base_klass: bar, version: 42 }
      let!(:foo_manifest13)  { create :manifest, base_klass: foo, version: 13 }

      let(:foo) { define_const("Foo", with_active_validation: true) }

      before do
        subject
        define_const "Foo::Validations::V13"
      end

      it "returns filtered results" do
        result = [bar_manifest42.as_hash_with_indifferent_access, bar_manifest1.as_hash_with_indifferent_access]
        expect(subject.find_manifests).to eq result
        expect(subject.find_manifests(base_klass: "Bar")).to eq result
      end

      it "find nothing and return HashWithIndifferentAccess" do
        expect(subject.find_manifest(version: 123)).to eq ActiveSupport::HashWithIndifferentAccess.new
      end

      it "return array if 1 element" do
        create :manifest, base_klass: bar, version: 55
        result = [bar_manifest42.as_hash_with_indifferent_access]
        expect(subject.find_manifests(base_klass: "Bar", version: 42)).to eq result
      end
    end
  end
end
