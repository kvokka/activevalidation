# frozen_string_literal: true

describe ActiveValidation::Verifier do
  subject do
    described_class.new(model) { |k| k.instance_variable_set :@bar, :setted }
  end

  let(:model) { define_model "Foo" }

  context "simple examples" do
    it "setups base klass" do
      expect(subject.base_klass).to eq model
    end

    it "yield provided block" do
      expect(subject.instance_variable_get(:@bar)).to eq :setted
    end
  end

  context "with restored configuration" do
    around do |example|
      backup = ActiveValidation.config.verifier_defaults
      example.call
      ActiveValidation.config.verifier_defaults(&backup)
    end

    it "setups defaults from configuration" do
      ActiveValidation.config.verifier_defaults { |k| k.instance_variable_set(:@test, :passed) }
      expect(subject.instance_variable_get(:@test)).to eq :passed
    end

    it "add self to minifests registry" do
      subject
      expect(ActiveValidation.config.verifiers_registry.find(model)).to eq subject
    end
  end
end
