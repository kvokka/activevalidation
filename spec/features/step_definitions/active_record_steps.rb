# frozen_string_literal: true

return unless ENV["ORM"] == "active_record"

step("class :string with active validation and superclass :klass") do |klass_name, super_klass|
  define_const(klass_name, superclass: super_klass).active_validation
end
