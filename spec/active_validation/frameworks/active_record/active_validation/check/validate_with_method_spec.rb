# frozen_string_literal: true

describe ActiveValidation::Check::ValidateWithMethod, helpers: %i[only_with_active_record] do
  it "provides the description of the validation class" do
    expect(described_class.argument_description).to match "^Should contain"
  end

  context "simple validator" do
    before do
      define_class("FooValidator", ActiveModel::Validator) { def validate(*); true; end }
    end

    it "is valid record with correct validator" do
      expect(build(:check_validate_with, argument: "FooValidator")).to be_valid
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

    it "is valid with nested record with correct validator" do
      define_class("NestedValidator", FooValidator)
      expect(build(:check_validate_with, argument: "NestedValidator")).to be_valid
    end
  end
end
