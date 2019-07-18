# frozen_string_literal: true

FactoryBot.define do
  factory :check_validate_with, class: "ActiveValidation::Check::ValidateWithMethod" do
    transient do
      # Generate validator for the argument
      with_validator_klass { true }
    end

    type { "ValidateWithMethod" }
    argument { "FooValidator" }

    after(:build) do |record, evaluator|
      next unless evaluator.with_validator_klass

      RSpec::Mocks::ConstantMutator.stub(record.argument, Class.new(ActiveModel::Validator))
    end
  end
end
