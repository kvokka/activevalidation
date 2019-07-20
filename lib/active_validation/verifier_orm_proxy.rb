# frozen_string_literal: true

module ActiveValidation
  class VerifierOrmProxy
    attr_reader :verifier

    def initialize(verifier)
      @verifier = verifier
    end

    delegate :base_klass,
             :version,
             :orm_adapter,
             :manifest_name_formatter,
             :as_hash_with_indifferent_access,
             to: :verifier

    def versions
      orm_adapter.versions verifier
    end

    def add_manifest(**manifest_hash)
      manifest_hash[:base_klass] ||= base_klass
      manifest_hash[:version]    ||= version
      orm_adapter.add_manifest manifest_hash
    end

    def find_manifest(**wheres)
      wheres[:base_klass] ||= base_klass

      orm_adapter.find_manifest(wheres)
    end

    def find_manifests(**wheres)
      wheres[:base_klass] ||= base_klass

      orm_adapter.find_manifests(wheres)
    end
  end
end
