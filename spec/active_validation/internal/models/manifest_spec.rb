# frozen_string_literal: true

describe ActiveValidation::Internal::Models::Manifest do
  subject { described_class.new version: 1, base_klass: "Foo" }

  before { define_const "Foo" }

  %i[version base_klass created_at checks options other].each do |m|
    it { is_expected.to have_attr_reader m }
  end

  %i[id created_at name].each do |m|
    it { is_expected.to delegate(m).to(:other) }
  end

  context "#class_name" do
    it "converts the method name to value object" do
      expect(subject.base_class).to eq Foo
    end
  end

  context "equality check" do
    it "if id is equal" do
      common = { version: 1, base_klass: "Foo", id: 42 }
      manifest1 = described_class.new common
      manifest2 = described_class.new common
      expect(manifest1).to eq manifest2
    end

    it "if attributes is equal, if even id are not" do
      common = { version: 1, base_klass: "Foo", checks: [], options: { bar: :baz } }
      manifest1 = described_class.new common.merge id: 1
      manifest2 = described_class.new common.merge id: 2
      expect(manifest1).to eq manifest2
    end
  end

  context "#to_hash" do
    it "converts to Hash with out coercion" do
      expect { Hash(subject) }.not_to raise_error
    end

    %i[version base_klass checks name id].each do |attr|
      it("should have '#{attr}' attribute") { expect(Hash(subject)[attr]).to be_truthy }
    end
  end
end
