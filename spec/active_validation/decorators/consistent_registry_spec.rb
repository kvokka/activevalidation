# frozen_string_literal: true

describe ActiveValidation::Decorators::ConsistentRegistry do
  subject { described_class.new(klass, registry) }

  let(:klass) { define_const("VerifierDouble") { def initialize(_arg); end } }
  let(:bar) { define_const "Bar" }

  let(:registry) { ActiveValidation::Registry.new("Great thing") }
  let(:inconsistent_error_class) { ActiveValidation::Errors::InconsistentRegistryError }

  let(:registered_object)        { instance_double("registered object") }

  context "#initialize" do
    context "raise" do
      it "raises an error if klass not provided" do
        expect { described_class.new(nil, registry) }.to raise_error NameError
      end

      it "raises an error if klass argument is not a class" do
        expect { described_class.new(:not_a_class, registry) }.to raise_error NameError
      end
    end

    it "works if klass provided as Class" do
      expect(subject).to be_a ActiveValidation::Registry
    end

    it "works if klass provided as String" do
      expect(described_class.new(klass.name, registry)).to be_a ActiveValidation::Registry
    end
  end

  it "have :klass reader" do
    decorator = described_class.new(klass, "name")

    expect(decorator.klass).to eq(klass)
  end

  context "#first_or_build" do
    context "existed record" do
      before { subject.register(bar.name, klass.new(bar)) }

      it "find" do
        expect(subject.find_or_build(bar.name)).to be_a klass
      end

      it "yield given block" do
        expect { |b| subject.find_or_build(bar.name, &b) }.to yield_control
      end
    end

    context "new record" do
      it "if not found build a new record" do
        expect(subject.find_or_build(klass.name)).to be_a klass
      end

      it "is not registered by registry by default" do
        subject.find_or_build(klass.name)
        expect(registry).not_to be_registered(klass.name)
      end

      it "yield given block on new record" do
        klass_instance = klass.new bar
        allow(klass).to receive(:new) do |record, &blk|
          expect(record).to eq bar
          expect(blk.call).to eq :passed
          klass_instance
        end

        subject.find_or_build(bar, &-> { :passed })
      end
    end
  end

  context "#find_or_add" do
    context "with existed record" do
      before { subject.register(bar.name, klass.new(bar)) }

      it "finds" do
        expect(subject.find_or_add(bar.name)).to be_a klass
      end

      it "do not try to add record to registry" do
        expect(registry).to include subject.find_or_add(bar.name)
        expect(registry.count).to eq 1
      end
    end

    context "with new record" do
      it "finds" do
        expect(subject.find_or_add(bar.name)).to be_a klass
      end

      it "add record to registry" do
        expect(registry).to include subject.find_or_add(bar.name)
        expect(registry.count).to eq 1
      end
    end
  end

  context "register" do
    context "raise" do
      it "with inconsistent value" do
        value = define_const "Wrong"
        expect { subject.register(bar.name, value) }.to raise_error ActiveValidation::Errors::InconsistentRegistryError
        expect { subject.find(bar.name) }.to raise_error KeyError
      end
    end

    it "registers the entry" do
      value = klass.new(bar)
      expect(subject.register(bar.name, value)).to eq value
      expect(subject.find(bar.name)).to eq value
    end
  end
end
