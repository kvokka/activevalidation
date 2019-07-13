# frozen_string_literal: true

module DefineConstantMacros
  def define_const(*paths, superclass: Object, type: Class, &block)
    paths.map do |path|
      const = stub_const(path, type.new(superclass))
      const.class_eval(&block) if block_given?
      const
    end.last
  end
end

RSpec.configure do |config|
  config.include DefineConstantMacros
end
