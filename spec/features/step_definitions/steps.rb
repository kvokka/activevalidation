# frozen_string_literal: true

step("class :string with active validation with out ORM") do |klass_name|
  define_const klass_name do
    include ActiveModel::Validations
    include ActiveValidation::ModelExtensionBase
    active_validation

    attr_accessor :manifest
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

step("variable :string in context ':string' :whether_to be valid") do |instance_var_name, context, expectation|
  instance = instance_variable_get "@#{instance_var_name}"
  expect(instance.valid?(context)).to eq expectation
end

step("class :klass instance :whether_to :be_matcher") do |klass, positive, matcher|
  expectation = positive ? :to : :not_to

  expect(klass.new).send expectation, send(matcher)
end

step("variable :string :whether_to :be_matcher") do |instance_var_name, positive, matcher|
  expectation = positive ? :to : :not_to
  instance = instance_variable_get "@#{instance_var_name}"

  expect(instance).send expectation, send(matcher)
end

step("klass :klass have method :string") do |klass, method_name|
  klass.send(:define_method, method_name) { nil }
end

# rubocop:disable Security/Eval
step(":klass have manifest version :version with checks:") do |klass, version, table|
  checks = table.rows.map do |(method_name, argument, options)|
    { method_name: method_name, argument: argument, options: eval(options) }
  end

  klass.active_validation.add_manifest checks_attributes: checks, version: version
end
# rubocop:enable Security/Eval

step("store :klass instance in :string variable") do |klass, variable|
  instance_variable_set("@#{variable}", klass.new)
end

step("variable :string method ':string' returns :string") do |instance_var_name, method_name, returns|
  variable = instance_variable_get("@#{instance_var_name}")
  variable.define_singleton_method(method_name) { returns }
end

step("variable :string error message :whether_to be on :string") do |instance_var_name, expectation, method_name|
  variable = instance_variable_get("@#{instance_var_name}")
  check_method = expectation ? :to : :to_not

  expect(variable.errors.messages).send(check_method, have_key(method_name.to_sym))
end

step("set active validation version for klass :klass to :version") do |klass, version|
  klass.active_validation.version = version.to_i
end

step("set variable :string manifest to :string") do |instance_var_name, state|
  variable = instance_variable_get("@#{instance_var_name}")
  variable.manifest = case state
                      when "current" then variable.class.active_validation.current_manifest
                      when "none" then nil
                      end
end
