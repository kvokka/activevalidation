# frozen_string_literal: true

describe ActiveValidation::Check::ValidatesWithMethod, type: :active_record do
  include_examples "check attributes check"

  it("contains field type") { expect(subject.attributes).to have_key("type") }

  context "simple validator" do
    before do
      define_const("FooValidator", superclass: ActiveModel::Validator) { def validate(*); true; end }
    end

    it "is valid record with correct validator" do
      expect(build(:check_validates_with, argument: "FooValidator")).to be_valid
    end

    it "is not valid record with incorrect validator" do
      record = build(:check_validates_with, argument: "NotExist", with_validator_klass: false)
      expect(record).not_to be_valid
      expect(record.errors[:argument].size).to eq 1
    end

    it "is not valid record without validator" do
      record = build(:check_validates_with, argument: "", with_validator_klass: false)
      expect(record).not_to be_valid
      expect(record.errors[:argument].size).to eq 1
    end

    it "is valid with nested record with correct validator" do
      define_const("NestedValidator", superclass: FooValidator)
      expect(build(:check_validates_with, argument: "NestedValidator")).to be_valid
    end
  end
end
