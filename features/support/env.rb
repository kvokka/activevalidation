# frozen_string_literal: true

ENV["ORM"] ||= "active_record"
ENV["DB"]  ||= "sqlite"

FEATURES_ROOT = Pathname.new(File.expand_path("..", __dir__))
GEM_ROOT = FEATURES_ROOT.join("../")

require "active_validation"
require "rspec"
require "pry"

Dir[GEM_ROOT.join("spec", "support", "*.rb")].each { |f| require f }
require GEM_ROOT.join("spec", "orm", ENV["ORM"], "setup")
