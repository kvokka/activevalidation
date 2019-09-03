# frozen_string_literal: true

placeholder :be_matcher do
  match(/be (\w+)/) do |name|
    "be_#{name}"
  end
end
