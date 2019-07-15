# frozen_string_literal: true

FactoryBot.define do
  factory :manifest, class: "ActiveValidation::Manifest" do
    transient do
      # Basics on this Array of Integers after build will be created
      # corresponding constants for the Manifest.
      with_versions { [] }
    end

    sequence(:name) { |n| "Manifest #{n}" }
    version { 1 }
    base_klass { "Foo" }

    %i[validate validates validate_with].each do |trait_name|
      trait(trait_name) do
        after(:build) { |record| record.checks << build(:"check_#{trait_name}") }
      end
    end

    after(:build) do |record, evaluator|
      records = Set.new evaluator.with_versions + [record.version]
      records.each do |n|
        constant_name = "#{record.base_klass}::Versions::V#{n}"
        RSpec::Mocks::ConstantMutator.stub(constant_name, Class.new)
      end
    end
  end
end
