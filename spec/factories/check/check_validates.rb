# frozen_string_literal: true

FactoryBot.define do
  factory :check_validates, class: "ActiveValidation::Check::ValidatesMethod" do
    type     { "ValidatesMethod" }
    argument { "name" }
    options  { { presence: true } }
  end
end
