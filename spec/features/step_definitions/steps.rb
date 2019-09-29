# frozen_string_literal: true

step("class :string with active validation with out ORM") do |klass_name|
  define_const klass_name do
    include ActiveModel::Validations
    include ActiveValidation::ModelExtensionBase
    active_validation
  end
end

step("defined versions are:") do |table|
  table.rows.each do |(klass_name, version)|
    define_const "#{klass_name}::Validations::V#{version}"
  end
end

step("active validation for class :klass installed") do |klass|
  klass.active_validation.install
end

step("class :klass instance in context ':string' :whether_to be valid") do |klass, context, expectation|
  expect(klass.new.valid?(context)).to eq expectation
end

step("class :klass instance :whether_to :be_matcher") do |klass, positive, matcher|
  expectation = positive ? :to : :not_to

  expect(klass.new).send expectation, send(matcher)
end

step("klass :klass have method :string") do |klass, method_name|
  klass.define_method(method_name) { nil }
end

# rubocop:disable Security/Eval
step(":klass have manifest with checks:") do |klass, table|
  checks = table.rows.map do |(method_name, argument, options)|
    { method_name: method_name, argument: argument, options: eval(options) }
  end

  klass.active_validation.add_manifest checks_attributes: checks
end
# rubocop:enable Security/Eval