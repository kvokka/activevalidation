# frozen_string_literal: true

module ActiveValidation
  module Internal
    module Observers
      class Manifest
        DISABLED_VERIFIER = :verifier_is_not_enabled
        RECENT_FAILURE = :it_was_failed_too_recently
        NOT_FOUND = :not_found
        ALREADY_INSTALLED = :already_installed
        INSTALLED = :installed
        UNINSTALLED = :uninstalled

        attr_reader :verifier, :installed_manifests, :last_failed_attempt_time

        delegate :manifest, :failed_attempt_retry_time, :enabled?, to: :verifier

        def initialize(verifier)
          @verifier = verifier
          @installed_manifests = Concurrent::Set.new
          @lock = Concurrent::ReadWriteLock.new
          @last_failed_attempt_time = nil
        end

        # Install manifest and store the result. Load priority:
        #   * `manifest_id` from the arguments
        #   * `verifier.manifest` - defined by user in verifier block
        #   * `current_manifest` - the latest manifest with current version
        #
        # The process will be skipped if:
        #   - `verifier` not `enabled?`
        #   - The last failed attempt was too recent.
        #
        # @return Symbol
        def install(manifest_id: nil)
          return DISABLED_VERIFIER unless enabled?
          return RECENT_FAILURE if attempt_to_was_failed_recently?

          found = lock.with_read_lock { find(manifest_id: manifest_id) } || current_manifest
          return  NOT_FOUND unless found
          return ALREADY_INSTALLED if found.installed?

          install! internal_manifest: found
        end

        # Uninstall the manifest.
        #
        # @return Symbol
        def uninstall(manifest_id:)
          lock.with_write_lock do
            internal_manifest = find(manifest_id: manifest_id)
            return NOT_FOUND unless internal_manifest&.installed?

            internal_manifest.uninstall
            installed_manifests.delete internal_manifest
          end
          UNINSTALLED
        end

        # We omit the error and only save the error time to prevent
        # DB flooding, when there is no any manifest.
        #
        # We do not know all possible errors so we can not be more
        # specific here.
        #
        # @return [Internal::Manifest]
        def current_manifest
          verifier.current_manifest.to_internal_manifest
        rescue StandardError => _e
          @last_failed_attempt_time = Time.now
          nil
        end

        # We need this method for been able to restore manifest lookup
        #
        # @return nil
        def reset_last_failed_attempt_time
          @last_failed_attempt_time = nil
        end

        # The actual install process
        #
        # @return Symbol
        def install!(internal_manifest:)
          lock.with_write_lock do
            return ALREADY_INSTALLED if find(manifest_id: internal_manifest.id)&.installed?

            internal_manifest.install
            installed_manifests << internal_manifest
          end
          INSTALLED
        end

        private

        attr_reader :lock

        def find(manifest_id: nil)
          return unless manifest_id

          @installed_manifests.detect do |manifest|
            manifest.id == manifest_id
          end
        end

        def attempt_to_was_failed_recently?
          return unless last_failed_attempt_time

          Time.now < @last_failed_attempt_time + failed_attempt_retry_time
        end
      end
    end
  end
end
