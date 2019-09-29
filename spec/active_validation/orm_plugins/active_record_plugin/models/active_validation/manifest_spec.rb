# frozen_string_literal: true

describe ActiveValidation::Manifest, type: :active_record do
  %i[update update_attribute update_attributes].each do |method|
    it "raises on #{method}" do
      expect { subject.send(method) }.to raise_error ActiveValidation::Errors::ImmutableError
    end
  end

  context "with existed model" do
    before do
      define_const("Foo", superclass: ActiveRecord::Base)
      define_const("FooValidator", superclass: ActiveModel::Validator)
    end

    it "accepts nested attributes for checks" do
      described_class.create name: "foo's manifest", version: 1, base_klass: "Foo", checks_attributes: [
        attributes_for(:check_validates),
        attributes_for(:check_validate),
        attributes_for(:check_validates_with)
      ]

      expect(described_class.count).to eq 1
      expect(ActiveValidation::Check.count).to eq 3
    end
  end

  context "factories traits" do
    %i[validate validates validates_with].each do |trait|
      it "accept Factory trait #{trait} and build corresponding check" do
        expect(build(:manifest, trait).checks.size).to eq 1
      end
    end
  end

  context "#to_internal_manifest" do
    let(:subject) { build :manifest, :validate }

    it "produces right class" do
      expect(subject.to_internal_manifest).to be_a ActiveValidation::Internal::Models::Manifest
    end

    context "has value" do
      %w[name version base_klass].each do |key|
        it key.to_s do
          expect(subject.to_internal_manifest.public_send(key)).to eq subject.public_send(key)
        end
      end

      context "checks" do
        subject { build(:manifest, :validate, :validates).to_internal_manifest.checks }

        let!(:wrong) { build(:manifest, :validate) }

        it { is_expected.to be_a Array }
        it { is_expected.to all a_kind_of ActiveValidation::Internal::Models::Check }
        it { is_expected.to have_attributes length: 2 }
      end
    end
  end
end
