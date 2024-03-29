# frozen_string_literal: true

describe ActiveValidation::Check, type: :active_record do
  it "return empty collection" do
    expect(described_class.all).to be_empty
  end

  %i[update update_attribute update_attributes].each do |method|
    it "raises on #{method}" do
      expect { subject.send(method) }.to raise_error ActiveValidation::Errors::ImmutableError
    end
  end

  context "#method_name" do
    it { expect { subject.method_name }.to raise_error NotImplementedError }
  end

  context "#method_name=" do
    it("Set correct type") do
      subject.method_name = "foo"
      expect(subject.type).to eq "FooMethod"
    end
  end

  context "#to_internal_check" do
    %i[check_validate check_validates check_validates_with].each do |type|
      context(type) do
        let(:subject) { build type }

        it "produces right class" do
          expect(subject.to_internal_check).to be_a ActiveValidation::Internal::Models::Check
        end

        context "has value" do
          %w[method_name argument].each do |key|
            it key.to_s do
              expect(subject.to_internal_check.public_send(key)).to eq subject.public_send(key)
            end

            it "options" do
              expect(subject.to_internal_check.options).to eq subject.options.deep_symbolize_keys
            end
          end
        end
      end
    end
  end
end
