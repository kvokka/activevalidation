# frozen_string_literal: true

FactoryBot.define do
  factory :check_validate, class: "ActiveValidation::Check::ValidateMethod" do
    argument { "foo_allowed" }
    options { {} }
  end
end
