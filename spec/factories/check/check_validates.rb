# frozen_string_literal: true

FactoryBot.define do
  factory :check_validates, class: "ActiveValidation::Check::ValidatesMethod" do
    argument { "name" }
    options  { { presence: true } }
  end
end
