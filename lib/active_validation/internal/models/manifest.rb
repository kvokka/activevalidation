# frozen_string_literal: true

module ActiveValidation
  module Internal
    module Models
      class Manifest
        attr_reader :version, :base_klass, :created_at, :checks, :options, :other, :id, :name

        def initialize(version:, base_klass:, checks: [], options: {}, **other)
          @version = ActiveValidation::Values::Version.new version
          @base_klass = base_klass.to_s
          @checks = Array(checks).map { |c| c.is_a?(Check) ? c : Check.new(c.to_options!) }
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
              acc[key_name] = send(k).as_json(v)
            end
            only.each { |el| acc[el.to_sym] = send(el).as_json }
          end
        end

        private

        def registry
          # ActiveValidation.config.method_name_values_registry
        end
      end
    end
  end
end
