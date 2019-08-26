# frozen_string_literal: true

Given("class {string} with active validation with out ORM") do |klass_name|
  klass = Class.new do
    include ActiveValidation::ModelExtensionBase
    include ActiveModel::Validations
    active_validation
  end

  klasses.register klass_name, klass
end

When("active validation for class {string} installed") do |klass_name|
  klasses.find(klass_name).active_validation.install
end

Then("class {string} instance should be valid") do |klass_name|
  expect(klasses.find(klass_name).new.valid?).to be_truthy
end
