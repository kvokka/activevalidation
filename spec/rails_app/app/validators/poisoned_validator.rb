# frozen_string_literal: true

class PoisonedValidator < SpoiledValidator
  def validate(record)
    super
    record.errors.add :base, "This record is poisoned" if name =~ /poisoned/
  end
end
