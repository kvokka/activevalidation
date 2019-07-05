# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActiveValidation::Orm::Finder do
  before do
    ActiveValidation::Orm::Base.all.each { |orm_klass| allow(orm_klass).to receive(:setup) }
  end

  context "::find!" do
    context "for pre-defined adapters" do
      [:mongoid, "mongoid", ActiveValidation::Orm::Plugins::Mongoid].each do |value|
        it "with #{value.inspect} config" do
          expect(subject.call(value)).to eq ActiveValidation::Orm::Plugins::Mongoid
        end
      end

      [:active_record, "active_record", ActiveValidation::Orm::Plugins::ActiveRecord].each do |value|
        it "with #{value.inspect} config" do
          expect(subject.call(value)).to eq ActiveValidation::Orm::Plugins::ActiveRecord
        end
      end
    end

    context "run setup block after for" do
      %w[mongoid active_record].each do |value|
        it value do
          expect(subject.call(value)).to have_received(:setup)
        end
      end
    end
  end
end
