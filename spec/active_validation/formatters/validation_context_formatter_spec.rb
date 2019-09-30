# frozen_string_literal: true

describe ActiveValidation::Formatters::ValidationContextFormatter do
  context "no options" do
    context "no name" do
      let(:manifest) do
        instance_double ActiveValidation::Internal::Models::Manifest, id: 23, options: {}, name: nil
      end

      it { expect(described_class.call(manifest)).to eq "active_validation_id23" }
    end

    context "with name" do
      let(:manifest) do
        instance_double ActiveValidation::Internal::Models::Manifest, id: 23, options: {}, name: :my_name
      end

      it { expect(described_class.call(manifest)).to eq "active_validation_id23_my_name" }
    end
  end

  context "with `on` option" do
    context "no name" do
      let(:manifest) do
        instance_double ActiveValidation::Internal::Models::Manifest, id: 23, options: { on: :new }, name: nil
      end

      it { expect(described_class.call(manifest)).to eq "active_validation_id23_on_new" }
    end

    context "with name" do
      let(:manifest) do
        instance_double ActiveValidation::Internal::Models::Manifest, id: 23, options: { on: :new }, name: :my_name
      end

      it { expect(described_class.call(manifest)).to eq "active_validation_id23_on_new_my_name" }
    end
  end
end
