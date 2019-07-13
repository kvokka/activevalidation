# frozen_string_literal: true

FactoryBot.define do
  factory :check_validate_with, class: "ActiveValidation::Check::ValidateWithMethod" do
    type { "ValidateWithMethod" }
    argument { "FooValidator" }
  end
end
