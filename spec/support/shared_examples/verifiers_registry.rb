# frozen_string_literal: true

RSpec.shared_context "verifiers registry" do |name = :registry|
  let(name) do
    registry = ActiveValidation::Decorators::DisallowsDuplicatesRegistry.new ActiveValidation::Registry.new("Dummy")
    ActiveValidation::Decorators::ConsistentRegistry.new ActiveValidation::Verifier, registry
  end

  before { allow(ActiveValidation.configuration).to receive(:verifiers_registry).and_return(send(name)) }
end
