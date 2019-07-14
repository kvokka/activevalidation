# frozen_string_literal: true

describe ActiveValidation::ModelExtension do
  context "::active_validation" do
    subject { Class.new { include ActiveValidation::ModelExtension } }

    let(:double) { double }

    it { is_expected.to respond_to :active_validation }

    it "pass forward the block" do
      expect { |b| subject.active_validation(&b) }.to yield_control
    end

    it "proxies self as an argument" do
      allow(::ActiveValidation::Verifier).to receive(:find_or_build).with(subject)
      subject.active_validation
      expect(::ActiveValidation::Verifier).to have_received(:find_or_build)
    end
  end
end
