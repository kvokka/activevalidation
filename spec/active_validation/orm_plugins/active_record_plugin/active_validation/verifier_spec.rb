# frozen_string_literal: true

describe ActiveValidation::Verifier, helpers: %i[only_with_active_record] do
  context "Manifest" do
    subject { described_class.find_or_build(bar) }

    let(:registry) do
      ActiveValidation::Decorators::DisallowsDuplicatesRegistry.new(ActiveValidation::Registry.new("Dummy"))
    end

    let(:bar) do
      define_const("Bar", with_active_validation: true) do
        active_validation { |c| c.as_hash_with_indifferent_access = false }
      end
    end

    before do
      allow(described_class).to receive(:registry).and_return(registry)

      subject
      define_const "Bar::Validations::V1"
      define_const "Bar::Validations::V42"
    end

    context "#add_manifest" do
      it "returns right class" do
        expect(subject.add_manifest).to be_a ActiveRecord::Base
      end
    end

    context "#find_manifest" do
      before do
        subject
        define_const "Bar::Validations::V42"
      end

      let!(:manifest) { create :manifest, base_klass: bar, version: 42 }

      it do
        expect(subject.find_manifest).to be_a ActiveRecord::Base
      end
    end
  end
end
