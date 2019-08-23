# frozen_string_literal: true

describe ActiveValidation::ModelExtensionBase do
  context "::active_validation" do
    let(:klass) { Class.new { include ActiveValidation::ModelExtensionBase } }

    it { expect(klass).to respond_to :active_validation }

    it "pass forward the block" do
      expect { |b| klass.active_validation(&b) }.to yield_control
    end

    it "proxies self as an argument" do
      allow(::ActiveValidation::Verifier).to receive(:find_or_build).with(klass)
      klass.active_validation
      expect(::ActiveValidation::Verifier).to have_received(:find_or_build)
    end

    context "register_active_validation_relations" do
      before do
        allow(::ActiveValidation::Verifier).to receive(:find_or_build)
        allow(klass).to receive(:register_active_validation_relations)
      end

      it "registers relations" do
        allow(::ActiveValidation::Verifier.registry).to receive(:registered?).and_return(false)
        klass.active_validation
        expect(klass).to have_received(:register_active_validation_relations)
      end

      it "does not register relations" do
        allow(::ActiveValidation::Verifier.registry).to receive(:registered?).and_return(true)
        klass.active_validation
        expect(klass).not_to have_received(:register_active_validation_relations)
      end
    end
  end
end
