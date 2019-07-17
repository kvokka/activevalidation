# frozen_string_literal: true

describe ActiveValidation::Manifest, helpers: %i[only_with_active_record] do
  %i[update update_attribute update_attributes].each do |method|
    it "should raise on #{method}" do
      expect { subject.send(method) }.to raise_error ActiveValidation::Errors::ImmutableError
    end
  end

  context "with existed model" do
    before do
      define_model("Foo") { def foo_allowed; end }
      define_const("FooValidator", superclass: ActiveModel::Validator)
    end

    it "accepts nested attributes for checks" do
      described_class.create name: "foo's manifest", version: 1, base_klass: "Foo", checks_attributes: [
        attributes_for(:check_validates),
        attributes_for(:check_validate),
        attributes_for(:check_validate_with)
      ]

      expect(described_class.count).to eq 1
      expect(ActiveValidation::Check.count).to eq 3
    end
  end

  context "factories traits" do
    %i[validate validates validate_with].each do |trait|
      it "accept Factory trait #{trait} and build corresponding check" do
        expect(build(:manifest, trait).checks.size).to eq 1
      end
    end
  end

  context "#as_hash_with_indifferent_access" do
    let(:subject) { build :manifest, :validate }

    it "produces right class" do
      expect(subject.with_indifferent_access).to be_a ActiveSupport::HashWithIndifferentAccess
    end

    context "has key" do
      %w[name version base_klass checks].each do |key|
        it key.to_s do
          expect(subject.with_indifferent_access).to have_key key
        end
      end
    end
  end
end
