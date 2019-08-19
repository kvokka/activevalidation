# frozen_string_literal: true

describe ActiveValidation::Formatters::ValidationContextFormatter do
  context "no options" do
    context "no name" do
      let(:manifest) do
        instance_double ActiveValidation::Internal::Models::Manifest, version: 42, options: {}, name: nil
      end

      it { expect(described_class.call(manifest)).to eq "active_validation_v42" }
    end

    context "with name" do
      let(:manifest) do
        instance_double ActiveValidation::Internal::Models::Manifest, version: 42, options: {}, name: :my_name
      end

      it { expect(described_class.call(manifest)).to eq "active_validation_v42_my_name" }
    end
  end

  context "with `on` option" do
    context "no name" do
      let(:manifest) do
        instance_double ActiveValidation::Internal::Models::Manifest, version: 42, options: { on: :new }, name: nil
      end

      it { expect(described_class.call(manifest)).to eq "active_validation_v42_on_new" }
    end

    context "with name" do
      let(:manifest) do
        instance_double ActiveValidation::Internal::Models::Manifest, version: 42, options: { on: :new }, name: :my_name
      end

      it { expect(described_class.call(manifest)).to eq "active_validation_v42_on_new_my_name" }
    end
  end
end
