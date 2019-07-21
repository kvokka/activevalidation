# frozen_string_literal: true

# # frozen_string_literal: true
#
# describe ActiveValidation::Verifier, helpers: %i[only_with_active_record] do
#   context "Manifest" do
#     subject { described_class.find_or_build(bar) }
#
#     let(:bar) do
#       define_const("Bar", with_active_validation: true) do
#         active_validation { |c| c.as_hash_with_indifferent_access = false }
#       end
#     end
#
#     include_examples "verifiers registry"
#
#     context "#add_manifest" do
#       it "returns right class" do
#         expect(subject.add_manifest).to be_a ActiveValidation::Internal::Models::Manifest
#       end
#     end
#
#     context "#find_manifest" do
#       let!(:manifest) { create :manifest, base_klass: bar, version: 42 }
#
#       it do
#         expect(subject.find_manifest).to be_a ActiveRecord::Base
#       end
#     end
#   end
# end
