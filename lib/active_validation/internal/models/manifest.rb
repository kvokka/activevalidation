# frozen_string_literal: true

using ActiveValidation::Internal::Models::Concerns::ToInternal::Check

module ActiveValidation
  module Internal
    module Models
      class Manifest
        attr_reader :version, :base_klass, :created_at, :checks, :options, :other, :id, :name

        # @param [Hash] Manifest options hash
        # @option manifest_hash [String] :name Human readable name, by default build with selected
        #         formatter for current manifest
        # @option manifest_hash [String, #to_s] :base_klass (base_klass) Base klass for the Manifest
        # @option manifest_hash [String, Symbol, Integer, Values::Version] :version (:current) Version
        #         of the current manifest
        # @option manifest_hash [Internal::Check] :checks ([])
        #
        # @example Add new manifest:
        #     new({  name: 'Cool Manifest',
        #        version: 42,
        #        base_klass: 'Bar',
        #        checks: [
        #           { method_name: "validates", argument: "name", options: { presence: true } }
        #        ]})
        def initialize(version:, base_klass:, checks: [], options: {}, **other)
          @version = ActiveValidation::Values::Version.new version
          @base_klass = base_klass.to_s
          @checks = Array(checks).map(&:to_internal_check)
          @other = ActiveSupport::OrderedOptions.new other

          @id = other[:id]
          @name = other[:name]
          @created_at = other[:created_at]
          @options = options.to_h.to_options!
        end

        def ==(other)
          return true if id == other.id

          version == other.version &&
            base_klass == other.base_klass &&
            options     == other.options &&
            checks      == other.checks
        end

        def base_class
          base_klass.constantize
        end

        def to_hash
          as_json
        end

        def install
          checks.each { |c| base_class.send(*c.to_send_arguments) }
        end

        # ActiveSupport#as_json interface
        # Supported options:
        #   :only [Array<Symbol>, Symbol] select only listed elements
        #
        # Nested elements accept options:
        #   :only [Array<Symbol>, Symbol] select only listed elements
        #   :as   [Symbol, String] in place rename for the column
        #
        # @example
        #     as_json(only: :version, checks: { as: :checks_attributes,
        #                                       only: [:argument] })
        #
        def as_json(only: %i[version base_klass checks name id], **options)
          only = Array(only)
          {}.tap do |acc|
            options.each_pair do |k, v|
              only.delete(k)
              as = v.delete(:as)
              key_name = (as || k).to_sym
              acc[key_name] = public_send(k).as_json(v)
            end
            only.each { |el| acc[el.to_sym] = public_send(el).as_json }
          end
        end

        def to_internal_manifest
          self
        end
      end
    end
  end
end
