# frozen_string_literal: true

class SpoiledValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add :base, "This record is spoiled" if name =~ /spoiled/
  end
end
