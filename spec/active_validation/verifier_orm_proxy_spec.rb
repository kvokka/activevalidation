# frozen_string_literal: true

# # frozen_string_literal: true
#
# describe ActiveValidation::VerifierOrmProxy do
#   subject { described_class.new ActiveValidation::Verifier.find_or_build "Bar" }
#
#   let!(:bar) { define_const "Bar", with_active_validation: true }
#
#   include_examples "verifiers registry"
#
#   %i[base_klass version orm_adapter manifest_name_formatter as_hash_with_indifferent_access].each do |m|
#     it { is_expected.to delegate(m).to(:verifier) }
#   end
#
#   context "#versions" do
#     before { allow(subject.orm_adapter).to receive(:versions) }
#
#     it "forwards to the orm_adapter" do
#       subject.versions
#       expect(subject.orm_adapter).to have_received(:versions).with(subject.verifier)
#     end
#   end
#
#   context "orm methods" do
#     context "#add_manifest" do
#       before do
#         allow(subject.orm_adapter).to receive(:add_manifest)
#         define_const "Bar::Validations::V17"
#       end
#
#       it "set defaults" do
#         subject.add_manifest
#         defaults = { base_klass: bar.to_s, version: ActiveValidation::Values::Version.new(17) }
#         expect(subject.orm_adapter).to have_received(:add_manifest).with(defaults)
#       end
#     end
#
#     context "#find_manifest" do
#       before { allow(subject.orm_adapter).to receive(:find_manifest) }
#
#       it "set defaults" do
#         subject.find_manifest
#         defaults = { base_klass: bar.to_s }
#         expect(subject.orm_adapter).to have_received(:find_manifest).with(defaults)
#       end
#     end
#
#     context "#find_manifests" do
#       before { allow(subject.orm_adapter).to receive(:find_manifests) }
#
#       it "set defaults" do
#         subject.find_manifests
#         defaults = { base_klass: bar.to_s }
#         expect(subject.orm_adapter).to have_received(:find_manifests).with(defaults)
#       end
#     end
#   end
# end
