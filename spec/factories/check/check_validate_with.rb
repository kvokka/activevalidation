# frozen_string_literal: true

FactoryBot.define do
  factory :check_validate_with, class: "ActiveValidation::Check::ValidateWithMethod" do
    argument { "FooValidator" }
  end
end
