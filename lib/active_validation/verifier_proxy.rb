# frozen_string_literal: true

# # frozen_string_literal: true
#
# module ActiveValidation
#   class VerifierProxy
#     attr_reader :verifier
#
#     def initialize(verifier)
#       @verifier = verifier
#     end
#
#     delegate :base_klass,
#              :version,
#              :orm_adapter,
#              :manifest_name_formatter,
#              :as_hash_with_indifferent_access,
#              to: :verifier
#
#     def versions
#       orm_adapter.versions verifier
#     end
#
#     def add_manifest(**manifest_hash)
#       normalize(manifest_hash) do |h|
#         h[:name] ||= manifest_name_formatter.call(base_klass)
#         h[:version] ||= version
#
#         orm_adapter.add_manifest(h)
#       end
#     end
#
#     def find_manifest(**wheres)
#       normalize(wheres) do |h|
#         orm_adapter.find_manifest h
#       end
#     end
#
#     def find_manifests(**wheres)
#       normalize(wheres) do |h|
#         orm_adapter.find_manifests h
#       end
#     end
#
#     private
#
#     def normalize(hash = {})
#       h = normalize_options(hash)
#       result = yield(h.dup)
#       raise(Errors::NotFoundError, "Manifest with #{h} not found") if result.blank?
#
#       normalize_records result
#     end
#
#     def normalize_options(hash = {})
#       h = ActiveSupport::HashWithIndifferentAccess.new hash
#       h[:base_klass]  ||= base_klass
#       h[:base_klass]    = h[:base_klass].name if h[:base_klass].is_a?(Class)
#       h
#     end
#
#     def normalize_records(hash_or_records)
#       return hash_or_records unless as_hash_with_indifferent_access
#       return hash_or_records.map(&:with_indifferent_access) if hash_or_records.respond_to?(:map)
#
#       hash_or_records.with_indifferent_access
#     rescue NoMethodError => e
#       raise unless e.name == :with_indifferent_access
#
#       raise Errors::MustRespondTo.new(base: hash_or_records, method_name: e.name)
#     end
#   end
# end
