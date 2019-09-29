# frozen_string_literal: true

return unless ENV["ORM"] == "active_record"

step("class :string with active validation") do |klass_name|
  define_const(klass_name, superclass: ActiveRecord::Base).active_validation
end
