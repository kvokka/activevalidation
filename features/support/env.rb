# frozen_string_literal: true

ENV["ORM"] ||= "active_record"
ENV["DB"]  ||= "sqlite"

FEATURES_ROOT = Pathname.new(File.expand_path("..", __dir__))
GEM_ROOT = FEATURES_ROOT.join("../")

require "active_validation"
require "rspec/expectations"
require "pry"

require GEM_ROOT.join("spec", "orm", ENV["ORM"], "setup")

module MyWorld
  def orm_base_class(orm = ENV["ORM"])
    case orm
    when "active_record" then ActiveRecord::Base
    else
      raise "Unsupportable ORM"
    end
  end

  def klasses
    @klasses ||= ActiveValidation::Registry.new "Initialised classes"
  end
end

World(MyWorld)
