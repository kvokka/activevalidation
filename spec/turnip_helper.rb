# frozen_string_literal: true

Dir.glob("spec/features/placeholders/**/*.rb") { |f| load f, true }
Dir.glob("spec/features/step_definitions/**/*steps.rb") { |f| load f, true }
