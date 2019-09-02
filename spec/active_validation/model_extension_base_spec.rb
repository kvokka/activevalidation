# frozen_string_literal: true

describe ActiveValidation::ModelExtensionBase do
  let(:klass) { Class.new { include ActiveValidation::ModelExtensionBase } }

  context "::active_validation" do
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

  context "#process_active_validation" do
    let(:verifier) { instance_double ::ActiveValidation::Verifier }

    before do
      allow(::ActiveValidation::Verifier).to receive(:find_or_build).with(klass).and_return(verifier)
      allow(verifier).to receive(:install!)
    end

    context "with manifest_id" do
      before do
        klass.define_method(:manifest_id) { 42 }
      end

      it "installs the manifest" do
        klass.new.send(:process_active_validation)
        expect(::ActiveValidation::Verifier).to have_received(:find_or_build)
        expect(verifier).to have_received(:install!).with(manifest_id: 42)
      end
    end

    context "with out manifest_id" do
      before do
        klass.define_method(:manifest_id) { nil }
      end

      it "installs the manifest" do
        klass.new.send(:process_active_validation)
        expect(::ActiveValidation::Verifier).to have_received(:find_or_build)
        expect(verifier).to have_received(:install!).with(manifest_id: nil)
      end
    end
  end
end
