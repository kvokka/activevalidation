# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActiveValidation::Orm do
  before do
    ActiveValidation::Orm::Base.all.each { |orm_klass| allow(orm_klass).to receive(:setup) }
  end

  context "::find!" do
    context "for pre-defined adapters" do
      [:mongoid, "mongoid", ActiveValidation::Orm::Mongoid].each do |value|
        it "with #{value.inspect} config" do
          expect(subject.find!(value)).to eq ActiveValidation::Orm::Mongoid
        end
      end

      [:active_record, "active_record", ActiveValidation::Orm::ActiveRecord].each do |value|
        it "with #{value.inspect} config" do
          expect(subject.find!(value)).to eq ActiveValidation::Orm::ActiveRecord
        end
      end
    end

    context "run setup block after for" do
      %w[mongoid active_record].each do |value|
        it value do
          expect(subject.find!(value)).to have_received(:setup)
        end
      end
    end
  end
end
