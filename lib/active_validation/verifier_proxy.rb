# frozen_string_literal: true

module ActiveValidation
  class VerifierProxy
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
      normalize(manifest_hash) do |h|
        h[:name] ||= manifest_name_formatter.call(base_klass)
        h[:version] ||= version

        orm_adapter.add_manifest(h)
      end
    end

    def find_manifest(**wheres)
      normalize(wheres) do |h|
        orm_adapter.find_manifest h
      end
    end

    def find_manifests(**wheres)
      normalize(wheres) do |h|
        orm_adapter.find_manifests h
      end
    end

    private

    def normalize(hash = {})
      h = ActiveSupport::HashWithIndifferentAccess.new hash
      unsupported_options = h.keys - supported_manifest_options
      raise ArgumentError, "Provided unsupported options #{unsupported_options}" if unsupported_options.any?

      h[:base_klass]  ||= base_klass
      h[:base_klass]    = h[:base_klass].name if h[:base_klass].is_a?(Class)
      result = yield h
      return result unless as_hash_with_indifferent_access
      return ActiveSupport::HashWithIndifferentAccess.new unless result
      return result.as_hash_with_indifferent_access unless result.respond_to?(:map)

      result.map(&:as_hash_with_indifferent_access)
    end

    def supported_manifest_options
      %w[base_klass name version checks created_at]
    end
  end
end
