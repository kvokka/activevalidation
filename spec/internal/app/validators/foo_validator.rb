# frozen_string_literal: true

class FooValidator < ActiveModel::Validator
  def validate(*)
    # noop
  end
end
