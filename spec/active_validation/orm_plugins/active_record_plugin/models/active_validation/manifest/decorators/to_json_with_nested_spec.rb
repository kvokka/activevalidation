# frozen_string_literal: true

describe ActiveValidation::Manifest::Decorators::ToJsonWithNested do
  let(:manifest) { build :manifest, :validate, :validates }

  it "produces right class" do
    expect(described_class.new(manifest).as_json).to be_a ActiveSupport::HashWithIndifferentAccess
  end

  context "has key" do
    %w[name version base_klass checks].each do |key|
      it key.to_s do
        expect(described_class.new(manifest).as_json).to have_key key
      end
    end
  end
end
