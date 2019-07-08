# frozen_string_literal: true

class Fruit < Food
  def self.validation_restricted_methods
    %i[foo_not_allowed]
  end
  private_class_method :validation_restricted_methods

  def foo_allowed; end

  def foo_not_allowed; end
end
