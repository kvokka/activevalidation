# frozen_string_literal: true

require "spec_helper"

RSpec.describe Check::ValidateWithMethod do
  it "provides the description of the validation class" do
    expect(described_class.argument_description).to match "^Should contain"
  end

  context "simple validator" do
    it "is valid record with correct validator" do
      expect(build(:check_validate_with, argument: "SpoiledValidator")).to be_valid
    end

    it "is not valid record with incorrect validator" do
      record = build(:check_validate_with, argument: "NotExist")
      expect(record).not_to be_valid
      expect(record.errors[:argument].size).to eq 1
    end

    it "is not valid record without validator" do
      record = build(:check_validate_with, argument: "")
      expect(record).not_to be_valid
      expect(record.errors[:argument].size).to eq 1
    end
  end

  context "nested validator" do
    it "is valid record with correct validator" do
      expect(build(:check_validate_with, argument: "PoisonedValidator")).to be_valid
    end
  end
end
