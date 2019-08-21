# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
FactoryBot.define do
  factory(:internal_check) do
    initialize_with { new(method_name: method_name, argument: argument, options: options) }
    options { {} }

    factory :internal_check_validate, class: "ActiveValidation::Internal::Models::Check" do
      method_name { "validate" }
      argument    { "my_method" }
    end

    factory :internal_check_validates, class: "ActiveValidation::Internal::Models::Check" do
      method_name { "validates" }
      argument    { "name" }
      options     { { "presence" => true } }
    end

    factory :internal_check_validates_with, class: "ActiveValidation::Internal::Models::Check" do
      transient do
        # Generate validator for the argument
        with_validator_klass { true }
      end

      method_name { "validates_with" }
      argument    { "MyValidator" }

      after(:build) do |record, evaluator|
        next unless evaluator.with_validator_klass

        klass = Class.new(ActiveModel::Validator) do
          def initialize(*); end

          def validate(*); end
        end

        RSpec::Mocks::ConstantMutator.stub(record.argument, klass)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
