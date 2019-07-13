# frozen_string_literal: true

FactoryBot.define do
  factory :manifest, class: "ActiveValidation::Manifest" do
    sequence(:name) { |n| "Manifest #{n}" }
    version { 1 }
    base_klass { "Foo" }

    %i[validate validates validate_with].each do |trait_name|
      trait(trait_name) do
        after(:build) { |record| record.checks << build(:"check_#{trait_name}") }
      end
    end
  end
end
