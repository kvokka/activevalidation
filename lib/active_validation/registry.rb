# frozen_string_literal: true

module ActiveValidation
  class Registry
    include Enumerable

    attr_reader :name

    def initialize(name)
      @name  = name
      @items = Concurrent::Map.new
    end

    def clear
      @items.clear
    end

    def each(&block)
      @items.values.uniq.each(&block)
    end

    def find(item_name)
      @items.fetch(normalize_name(item_name))
    rescue KeyError => e
      raise key_error_with_custom_message(e, item_name)
    end

    alias [] find

    def register(name, item)
      @items[normalize_name(name)] = item
    end

    def registered?(name)
      @items.key?(normalize_name(name))
    end

    def delete(name)
      @items.delete(normalize_name(name))
    end

    private

    def key_error_with_custom_message(key_error, item_name)
      message = key_error.message.sub("key not found", %(#{@name} not registered: "#{item_name}"))
      error = KeyError.new(message)
      error.set_backtrace(key_error.backtrace)
      error
    end

    def normalize_name(key)
      key.respond_to?(:to_sym) ? key.to_sym : key.to_s.to_sym
    end
  end
end
