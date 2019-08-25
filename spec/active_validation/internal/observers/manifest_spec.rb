# frozen_string_literal: true

describe ActiveValidation::Internal::Observers::Manifest do
  subject { described_class.new verifier }

  let(:manifest_id) { 42 }
  let(:manifest) { instance_double ActiveValidation::Internal::Models::Manifest }
  let(:verifier) { instance_double ActiveValidation::Verifier, enabled?: true }

  %i[manifest failed_attempt_retry_time enabled?].each do |m|
    it { is_expected.to delegate(m).to(:verifier) }
  end

  context "#current_manifest" do
    let(:verifier) { instance_double ActiveValidation::Verifier, current_manifest: manifest }

    context "no raise" do
      before do
        allow(manifest).to receive(:to_internal_manifest).and_return(manifest)
      end

      it("return current manifest") { expect(subject.current_manifest).to eq manifest }
    end

    context "raise" do
      let(:error) { StandardError }
      let(:time)  { Time.now }

      before do
        allow(manifest).to receive(:to_internal_manifest).and_raise(error)
        allow(Time).to receive(:now).and_return(time)
      end

      it("error is not raised and nil returned") { expect { subject.current_manifest }.not_to raise_error }
      it("last_failed_attempt_time set") do
        subject.current_manifest
        expect(subject.last_failed_attempt_time).to eq time
      end

      it("returns nil") { expect(subject.current_manifest).to be_nil }
    end
  end

  context "#reset_last_failed_attempt_time" do
    it("resets the variable") do
      subject.instance_variable_set("@last_failed_attempt_time", "some_value")
      expect(subject.reset_last_failed_attempt_time).to be_nil
    end
  end

  # rubocop:disable RSpec/SubjectStub
  context "#install" do
    context "not enabled" do
      let(:verifier) { instance_double ActiveValidation::Verifier, enabled?: false }

      it("returns status") { expect(subject.install).to eq described_class::DISABLED_VERIFIER }
    end

    context "attempt_to_was_failed_recently?" do
      before do
        allow(subject).to receive(:attempt_to_was_failed_recently?).and_return(true)
      end

      it("returns status") { expect(subject.install).to eq described_class::RECENT_FAILURE }
    end

    context "with not found manifest" do
      before do
        allow(subject).to receive(:current_manifest)
      end

      it("returns status") { expect(subject.install).to eq described_class::NOT_FOUND }
    end

    context "with found manifest" do
      context "already_installed" do
        context "found" do
          let(:manifest) do
            instance_double ActiveValidation::Internal::Models::Manifest, installed?: true, id: manifest_id
          end

          before do
            subject.installed_manifests << manifest
          end

          it("returns status") do
            expect(subject.install(manifest_id: manifest_id)).to eq described_class::ALREADY_INSTALLED
          end
        end

        context "current" do
          let(:another_manifest) { instance_double ActiveValidation::Internal::Models::Manifest, installed?: true }

          before do
            allow(subject).to receive(:current_manifest).and_return(another_manifest)
          end

          it("returns status") { expect(subject.install).to eq described_class::ALREADY_INSTALLED }
        end
      end

      context "required to be installed" do
        before do
          allow(subject).to receive(:install!)
        end

        context "found" do
          let(:manifest) do
            instance_double ActiveValidation::Internal::Models::Manifest, installed?: false, id: manifest_id
          end

          before do
            subject.installed_manifests << manifest
          end

          it("returns status") do
            subject.install(manifest_id: manifest_id)
            expect(subject).to have_received :install!
          end
        end

        context "current" do
          let(:another_manifest) { instance_double ActiveValidation::Internal::Models::Manifest, installed?: false }

          before do
            allow(subject).to receive(:current_manifest).and_return(another_manifest)
          end

          it("returns status") do
            subject.install
            expect(subject).to have_received :install!
          end
        end
      end
    end
  end

  context "private #install!" do
    context "already installed" do
      let(:manifest) do
        instance_double ActiveValidation::Internal::Models::Manifest, installed?: true, id: manifest_id
      end

      it("returns status") do
        subject.installed_manifests << manifest
        expect(subject.install!(internal_manifest: manifest)).to eq described_class::ALREADY_INSTALLED
      end
    end

    context "new installation" do
      let(:manifest) do
        instance_double ActiveValidation::Internal::Models::Manifest, installed?: false, id: manifest_id, install: nil
      end

      it "installed manifest include the manifest" do
        subject.install!(internal_manifest: manifest)
        expect(subject.installed_manifests).to include manifest
      end

      it "run install method in the manifest" do
        subject.install!(internal_manifest: manifest)
        expect(manifest).to have_received(:install)
      end

      it("returns status") do
        expect(subject.install!(internal_manifest: manifest)).to eq described_class::INSTALLED
      end
    end
  end
  # rubocop:enable RSpec/SubjectStub

  context "uninstall" do
    context "with not found manifest" do
      it("returns status") { expect(subject.uninstall(manifest_id: manifest_id)).to eq described_class::NOT_FOUND }
    end

    context "found" do
      let(:manifest) do
        instance_double ActiveValidation::Internal::Models::Manifest, installed?: true, id: manifest_id, uninstall: nil
      end

      before do
        subject.installed_manifests << manifest
      end

      it("returns status") do
        expect(subject.uninstall(manifest_id: manifest_id)).to eq described_class::UNINSTALLED
      end

      it "run uninstall method in the manifest" do
        subject.uninstall(manifest_id: manifest_id)
        expect(manifest).to have_received(:uninstall)
      end

      it "installed manifest include the manifest" do
        subject.uninstall(manifest_id: manifest_id)
        expect(subject.installed_manifests).to be_empty
      end
    end
  end
end
