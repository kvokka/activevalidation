# frozen_string_literal: true

FactoryBot.define do
  factory :check_validate, class: "ActiveValidation::Check::ValidateMethod" do
    type     { "ValidateMethod" }
    argument { "foo_allowed" }
  end
end
