# frozen_string_literal: true

module DefineConstantMacros
  def define_const(path, superclass: Object, type: Class, &block)
    const = stub_const(path, type.new(superclass))
    const.class_eval(&block) if block_given?
    const
  end

  def define_consts(*paths, **opt, &block)
    paths.map { |path| define_const(path, opt, &block) }
  end
end

RSpec.configure do |config|
  config.include DefineConstantMacros
end
