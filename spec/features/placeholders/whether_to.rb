# frozen_string_literal: true

placeholder :whether_to do
  match(/should not/) do
    false
  end

  match(/should/) do
    true
  end
end
